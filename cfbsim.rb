## Set up
CONFERENCES = ["ACC", "Big12", "BigTen", "PAC12", "SEC"].freeze

teams = Array.new

def add_teams(array, conf, num)
  num.times { array << conf }
end

add_teams(teams, "ACC", 14)
add_teams(teams, "Big12", 10)
add_teams(teams, "BigTen", 14)
add_teams(teams, "PAC12", 12)
add_teams(teams, "SEC", 14)

class Conference
  attr_reader :name, :best, :top_25, :playoff_teams

  def initialize(name, best, in_playoffs, top_25)
    @name = name
    @best = best
    @playoff_teams = in_playoffs
    @top_25 = top_25
  end
end

class Season
  attr_reader :playoff_conferences,
              :second_best, :third_best, :fourth_best, :worst_best,
              :most_top25, :second_top25,
              :third_top25, :fourth_top25, :worst_top25

  def initialize(results)
    ##Key Summary Stats
    @playoff_conferences = 0
    @best_ranks = Array.new
    @top25_counts = Array.new

    results.each do |conf|
      @playoff_conferences += 1 if conf.playoff_teams > 0
      @best_ranks << conf.best
      @top25_counts << conf.top_25
    end

    @best_ranks = @best_ranks.sort

    @second_best = @best_ranks[1]
    @third_best = @best_ranks[2]
    @fourth_best = @best_ranks[3]
    @worst_best = @best_ranks[4]

    @top25_counts = @top25_counts.sort { |x, y| y <=> x }

    @most_top25 = @top25_counts[0]
    @second_top25 = @top25_counts[1]
    @third_top25 = @top25_counts[2]
    @fourth_top25 = @top25_counts[3]
    @worst_top25 = @top25_counts[4]
  end
end

def get_true_ranks(teams)
  shuffled = teams.shuffle

  ranked = shuffled.take(25)
  remaining = shuffled.drop(25)

  until all_conferences?(ranked)
    ranked << remaining.shift
  end

  ranked
end

def all_conferences?(array)
  CONFERENCES.each { |conf| return false unless array.include?(conf) }
  true
end

def sim_season(teams)
  ranked = get_true_ranks(teams)

  top_25 = ranked.take(25)

  results = Array.new

  CONFERENCES.each { |conf| results << get_results(conf, ranked, top_25) }

  Season.new(results)
end

def get_results(conference, ranked, top_25)

  highest_rank = ranked.find_index(conference) + 1
  in_top_25 = top_25.count(conference)
  playoffs = ranked.take(4).count(conference)

  Conference.new(conference, highest_rank, playoffs, in_top_25)
end

seasons = Array.new
sims = 1000000

sims.times { seasons << sim_season(teams) }

four_playoff_conferences = 0
three_playoff_conferences = 0
two_playoff_conferences = 0
one_playoff_conference = 0

second_best_avg = 0
third_best_avg = 0
fourth_best_avg = 0
worst_best_avg = 0

most_top25_avg = 0
second_top25_avg = 0
third_top25_avg = 0
fourth_top25_avg = 0
worst_top25_avg = 0


seasons.each do |season|
  case season.playoff_conferences
  when 4
    four_playoff_conferences += 1
  when 3
    three_playoff_conferences += 1
  when 2
    two_playoff_conferences += 1
  else
    one_playoff_conference += 1
  end

  second_best_avg += season.second_best
  third_best_avg += season.third_best
  fourth_best_avg += season.fourth_best
  worst_best_avg += season.worst_best

  most_top25_avg += season.most_top25
  second_top25_avg += season.second_top25
  third_top25_avg += season.third_top25
  fourth_top25_avg += season.fourth_top25
  worst_top25_avg += season.worst_top25
end

puts "Four Playoff Conferences: #{four_playoff_conferences * 100 / sims.to_f}%"
puts
"Three Playoff Conferences: #{three_playoff_conferences * 100 / sims.to_f}%"
puts "Two Playoff Conferences: #{two_playoff_conferences * 100 / sims.to_f}%"
puts "One Playoff Conference: #{one_playoff_conference * 100 / sims.to_f}%"

puts "Second best average: #{second_best_avg / sims.to_f}"
puts "Third best average: #{third_best_avg / sims.to_f}"
puts "Fourth best average: #{fourth_best_avg / sims.to_f}"
puts "Worst best average: #{worst_best_avg / sims.to_f}"

puts "Most Top 25 average: #{most_top25_avg / sims.to_f}"
puts "Second Top 25 average: #{second_top25_avg / sims.to_f}"
puts "Third Top 25 average: #{third_top25_avg / sims.to_f}"
puts "Fourth Top 25 average: #{fourth_top25_avg / sims.to_f}"
puts "Worst Top 25 average: #{worst_top25_avg / sims.to_f}"

# season = sim_season(teams)
#
# puts "Playoff conferences: #{season.playoff_conferences}"
# puts "2nd best conference champ: #{season.second_best}"
# puts "3rd best conference champ: #{season.third_best}"
# puts "4th best conference champ: #{season.fourth_best}"
# puts "Worst conference champ: #{season.worst_best}"
#
# puts "Most top 25: #{season.most_top25}"
# puts "Second most top 25: #{season.second_top25}"
# puts "Third most top 25: #{season.third_top25}"
# puts "Fourth most top 25: #{season.fourth_top25}"
# puts "Least top 25: #{season.worst_top25}"
