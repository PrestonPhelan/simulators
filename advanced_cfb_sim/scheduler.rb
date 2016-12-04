require_relative 'team'
require_relative 'sim'
require 'byebug'

def generate_full_schedule(teams)
  games = Array.new

  conference_hash = new_conference_hash(teams)
  division_hash = new_division_hash(teams)

  games += g5_games(teams)
  games += generate_non_conference_games(conference_hash)
  games += seven_team_division_games(division_hash, :ACC)
  games += seven_team_division_games(division_hash, :Big_Ten)
  games += seven_team_division_games(division_hash, :SEC)
  games += large_interdivision_games(division_hash, :ACC)
  games += large_interdivision_games(division_hash, :Big_Ten)
  games += large_interdivision_games(division_hash, :SEC)
  games += six_team_division_games(division_hash, :PAC_12)
  games += pac_12_interdivision_games(division_hash)
  games += big_12_games(conference_hash)

  games
end

##Non-Conference Schedule
##Each team gets a random game against another non-conference P5 school

def generate_non_conference_games(conference_hash)
  clone_hash = conference_hash.clone
  clone_hash.each do |k, v|
    clone_hash[k] = v.shuffle
  end

  games = Array.new

  4.times do
    games << take_teams(clone_hash, :ACC, :SEC)
    games << take_teams(clone_hash, :Big_Ten, :ACC)
    games << take_teams(clone_hash, :Big_Ten, :SEC)
    games << take_teams(clone_hash, :Big_Ten, :PAC_12)
  end

  3.times do
    games << take_teams(clone_hash, :ACC, :PAC_12)
    games << take_teams(clone_hash, :ACC, :Big_12)
    games << take_teams(clone_hash, :SEC, :PAC_12)
    games << take_teams(clone_hash, :SEC, :Big_12)
  end

  2.times do
    games << take_teams(clone_hash, :Big_Ten, :Big_12)
    games << take_teams(clone_hash, :Big_12, :PAC_12)
  end

  clone_hash.each do |k, v|
    raise "Didn't properly empty #{k}, still has #{v}" unless v.empty?
  end

  games
end

def take_teams(conference_hash, conf1, conf2)
  matchup = [conference_hash[conf1].pop, conference_hash[conf2].pop]
  matchup.shuffle
end

##Each team gets a two home games agains G5 schools
#G5_TEAMS.shuffle.take(2)
def g5_games(teams)
  games = Array.new
  teams.each do |team|
    2.times do
      games << [team, G5_RATINGS.sample]
    end
  end

  games
end

##Conference Schedule, CONSTANT sim-to-sim
##14-team conferences: 6 division games, 3 other division
def seven_team_division_games(division_hash, conference)
  games = Array.new
  divisions = TEAMS[conference].keys
  divisions.each do |division|
    teams = division_hash["#{conference} #{division}"].shuffle

    teams.each_with_index do |team, idx|
      games << [team, teams[idx - 1]]
      games << [team, teams[idx - 2]]
      games << [team, teams[idx - 3]]
    end
  end

  games
end

def six_team_division_games(division_hash, conference)
  games = Array.new
  divisions = TEAMS[conference].keys
  divisions.each do |division|
    teams = division_hash["#{conference} #{division}"].shuffle

    teams.each_with_index do |team, idx|
      games << [team, teams[idx - 1]]
      games << [team, teams[idx - 2]]
      games << [team, teams[idx - 3]] if idx < 3
    end
  end

  games
end

def large_interdivision_games(division_hash, conference)
  games = Array.new
  divisions = TEAMS[conference].keys.shuffle

  first_division = division_hash["#{conference} #{divisions[0]}"].shuffle
  second_division = division_hash["#{conference} #{divisions[1]}"].shuffle

  first_division.each_with_index do |team, idx|
    games << [team, second_division[idx - 1]]
    games << [team, second_division[idx - 2]] if idx < 4
  end

  second_division.each_with_index do |team, idx|
    games << [team, first_division[idx - 1]]
    games << [team, first_division[idx - 5]] if idx > 1 && idx < 5
  end

  games
end

def pac_12_interdivision_games(division_hash)
  games = Array.new
  north = division_hash["PAC_12 North"].shuffle
  south = division_hash["PAC_12 South"].shuffle

  north.each_with_index do |team, idx|
    2.times { |i| games << [team, south[idx - i - 1]] }
  end

  north.each_with_index do |team, idx|
    2.times { |i| games << [team, south[idx - i - 1]] }
  end

  games
end

def big_12_games(conference_hash)
  games = Array.new

  teams = conference_hash[:Big_12].shuffle

  teams.each_with_index do |team, idx|
    4.times do |i|
      games << [team, teams[idx - i - 1]]
    end
    games << [team, teams[idx - 5]] if idx < 5
  end

  games
end


# division_hash = new_division_hash(Team.create_all)
# games = large_interdivision_games(division_hash, :Big_Ten)
#
# games.each do |matchup|
#   print matchup.map(&:to_s)
#   puts
# end
#
# puts "#{games.length} games generated."
#
# division_hash["Big_Ten East"].each do |team|
#   puts "#{games.flatten.count(team)} games for #{team}"
# end
#
# division_hash["Big_Ten West"].each do |team|
#   puts "#{games.flatten.count(team)} games for #{team}"
# end

# teams = Team.create_all
# games = big_12_games(new_conference_hash(teams))

# puts games.class
#
# games.each do |matchup|
#   print matchup.map(&:to_s)
#   puts
# end
#
# puts "#{games.length} games generated."
#
if __FILE__ == $0
  teams = Team.create_all
  games = generate_full_schedule(teams)

  puts "#{games.length} games generated, #{32 * 10 + 128} expected"
  5.times do
    print games.sample.map(&:to_s)
    puts
  end

  teams.each do |team|
    team_games = games.flatten.count(team)
    puts "Error: #{team_games} games generated for #{team}" unless team_games == 12
  end
end
