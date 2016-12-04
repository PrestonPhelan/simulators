require_relative 'team'
require_relative 'sim'

##Non-Conference Schedule
##Each team gets a random game against another non-conference P5 school
def generate_non_conference_games
  team_hash = new_conference_hash(Team.create_all)
  team_hash.each do |k, v|
    team_hash[k] = v.shuffle
  end

  games = Array.new

  4.times do
    games << take_teams(team_hash, :ACC, :SEC)
    games << take_teams(team_hash, :Big_Ten, :ACC)
    games << take_teams(team_hash, :Big_Ten, :SEC)
    games << take_teams(team_hash, :Big_Ten, :PAC_12)
  end

  3.times do
    games << take_teams(team_hash, :ACC, :PAC_12)
    games << take_teams(team_hash, :ACC, :Big_12)
    games << take_teams(team_hash, :SEC, :PAC_12)
    games << take_teams(team_hash, :SEC, :Big_12)
  end

  2. times do
    games << take_teams(team_hash, :Big_Ten, :Big_12)
    games << take_teams(team_hash, :Big_12, :PAC_12)
  end

  team_hash.each do |k, v|
    raise "Didn't properly empty #{k}, still has #{v}" unless v.empty?
  end

  games
end

def take_teams(team_hash, conf1, conf2)
  matchup = [team_hash[conf1].pop, team_hash[conf2].pop]
  matchup.shuffle
end

  ##Each team gets a two home games agains G5 schools
  #G5_TEAMS.shuffle.take(2)

##Conference Schedule, CONSTANT sim-to-sim
  ##14-team conferences: 6 division games, 3 other division
def seven_team_division_games(division_hash, conference)
  games = Array.new
  divisions = TEAMS[conference].keys
  divisions.each do |division|
    teams = division_hash["#{conference.to_s} #{division.to_s}"].shuffle

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
    teams = division_hash["#{conference.to_s} #{division.to_s}"].shuffle

    teams.each_with_index do |team, idx|
      games << [team, teams[idx - 1]]
      games << [team, teams[idx - 2]]
      games << [team, teams[idx - 3]] if idx < 3
    end
  end

  games
end
  ##Pac-12: 5 division game, 4 other division
  ##Big 12: Every other team round robin
def big_12_games(conference_hash)
  games = Array.new
  teams = conference_hash[:Big_12].shuffle

  teams.each_with_index do |team, idx|
    4.times do |i|
      games << [team, teams[idx - i]]
    end
    games << [team, teams[idx - 5]] if idx < 5
  end

  games
end

conference_hash = new_conference_hash(Team.create_all)
games = big_12_games(conference_hash)

puts "#{games.length} games generated."

games.each do |matchup|
  print matchup.map(&:to_s)
  puts
end
