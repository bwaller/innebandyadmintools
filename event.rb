# encoding: utf-8

require 'date'

class Event

  @@stats_base_url = "http://statistik.innebandy.se/"
  @@event_base_url = @@stats_base_url + "ft.aspx?scr=result&fmid="

  attr_accessor :id, :url, :home_team, :away_team, :number, :start_time, :end_time, :venue, :serie

  def initialize(id, team_id, serie, length_m = 60)
    @id = id
    @url = @@event_base_url + id.to_s
    @serie = serie
    @is_valid = false
    @is_home = true
    event_html = Nokogiri::HTML(open(@url))
    node_set = event_html.css('td:contains("Laguppställning")') 
    if node_set.to_a.length == 2
      @is_valid = true
      home_team_id = @serie.teams[node_set.to_a[0].content.gsub("Laguppställning","").strip]
      away_team_id = @serie.teams[node_set.to_a[1].content.gsub("Laguppställning","").strip]
      @home_team = Team.new(home_team_id, @serie.id)
      @away_team = Team.new(away_team_id, @serie.id)
      @is_valid = false if @home_team.name.nil? 
      @is_valid = false if @away_team.name.nil? 
      team_id.to_i == home_team_id.to_i ? @is_home = true : @is_home = false  
    else
      puts "What the fuck..?"
    end
   
    venue_id = 0
    elem = event_html.at('td:contains("Spelplats")')
    if elem
      venue_id = elem.next_element.child["href"].match(/[0-9]*$/).to_s.to_i 
      @venue = Venue.new(venue_id)
    else
      @venue = nil  
    end

    @number = 0
    elem = event_html.at('td:contains("Matchnummer")')
    if elem 
      @number = elem.next_element.content
    end
    if @number == 0 then
      serie_html = Nokogiri::HTML(open(@serie.url))
      number = serie_html.css("html body div#container div#IbisInfo.ibisinfo table.clCommonGrid tbody.clGrid tr").each do |tr|
        #puts tr.children.to_a[5] if tr.children.to_a[5].["href"].match(/125930/)
        #puts tr.children.to_a[5] 
        #puts "start "+tr.class.to_s, tr.element_children.to_a.length?, "end"
        if tr.element_children.length == 6 then
          @number = tr.element_children[2].child.content if tr.element_children[2].child["href"].match(@id.to_s)
        end
      end
    end

    start_time_str = "1970-01-01"
    elem = event_html.at('td:contains("Tid")')
    if elem && elem.next_element && elem.next_element.content.match(/./)
      start_time_str = elem.next_element.content
    end                  
    @start_time = DateTime.parse (start_time_str)
    @end_time = @start_time + Rational(length_m,24*60)
    @is_valid = false if (@start_time.year == 1970)
  end

  def is_valid?
    return @is_valid
  end

  def is_home?
    return @is_home
  end

  def is_away?
    return !@is_home
  end

  def length
    minutes = (@end_time - @start_time).to_f*24*60
    return minutes
  end

  def self.stats_base_url
    return @@stats_base_url
  end

  def anchor(attributes, content)
    return "<a " + attributes + " href=" + @url + ">" + content + "</a>"
  end

  def anchor_matchtrupp(attributes, content)
    return "<a " + attributes + " href=\"https://ibis.innebandy.se/Fogisforeningklient/Match/MatchTrupp.aspx?matchId=" + @id.to_s + "\">" + content + "</a>"
  end

  def to_s
    ans = @id.to_s 
    ans += " " + @url 
    ans += " " + @number.to_s
    ans += " " + @home_team.name
    ans += " " + @away_team.name
    ans += " " + @serie.name
    ans += " " + @start_time.to_s
    ans += " " + @end_time.to_s
    ans += " " + @venue.id.to_s
    return ans + " " + is_home?.to_s 
  end
end # Event

