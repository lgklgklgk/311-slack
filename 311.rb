require "mechanize"

slack_url   = "Define your slack webhook URL here."
agent       = Mechanize.new
page        = agent.get("http://www.311.com/lyrics")
links       = page.links_with(:href => /http:\/\/www\.311\.com\/lyrics/)
begin
	song        = links.sample
	song_page   = song.click
	doc         = song_page.parser
	element     = doc.at("h5:contains('#{song.text}')")
	lyric_array = []
	until element.next_element.name == "h5"
		element = element.next_element
		lyric_array << element.text
	end
rescue StandardError
	retry
end
lyric_array.reject!(&:empty?)
lyric_array.delete_if{|a| a.include? "* Thanks to "}
lyric = "CHORUS"
until lyric != "CHORUS"
	lyric = lyric_array.sample
end
`curl -X POST --data-urlencode 'payload={"text": "#{lyric}"}' #{slack_url}`
