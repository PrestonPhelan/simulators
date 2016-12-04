require_relative 'team'
require_relative 'scheduler'
require_relative 'season'
require 'byebug'
require 'rubystats'

##DEFINE RATINGS CONSTANTS
G5_RATINGS = File.readlines('g5_ratings.txt').map(&:to_f).freeze
RATINGS = File.readlines('p5_ratings.txt').map(&:to_f).freeze

def new_conference_hash(teams)
  conferences = Hash.new { Array.new }

  teams.each do |team|
    conferences[team.conference] += [team]
  end

  conferences
end

def new_division_hash(teams)
  divisions = Hash.new { Array.new }

  teams.each do |team|
    string = "#{team.conference} #{team.division}"
    divisions[string] += [team]
  end
  divisions
end

def get_sims(playoff_size, num)
  sims = Array.new
  num.times do
    new_season = Season.new(playoff_size)
    new_season.run
    sims << new_season
  end

  sims
end

def champ_counts(sims, rank)
  sims.map { |season| season.champion.true_rank }.count(rank)
end


if __FILE__ == $0
  two_team_sims = []
  1000.times do
    new_season = Season.new(2)
    new_season.run
    two_team_sims << new_season
  end

  four = []
  1000.times do
    new_season = Season.new(2)
    new_season.run
    two_team_sims << new_season
  end
  # best_team_wins = 0
  # best_made_playoffs = 0
  # undefeateds = 0
  # conferences_represented = 0
  # all_different = 0
  # 1000000.times do
  #   teams = Team.create_all
  #   results = run_season(teams)
  #   best_team_wins += 1 if results[0].true_rank == 1
  #   best_made_playoffs += 1 if results[1]
  #   undefeateds += results[2]
  #   conferences_represented += results[3]
  #   all_different += 1 if results[4]
  # end
  #
  # puts "Best team won #{best_team_wins} times out of a million."
  # puts "Best team made playoffs #{best_made_playoffs} times."
  # puts "There were an average of #{undefeateds / 1000000.0} undefeated regular season teams."
  # puts "There were an average of #{conferences_represented / 1000000.0} conferences in the playoffs."
  # puts "Four different conferences were represented #{all_different} times."
  # 5.times do
  #   sample = teams.sample
  #   puts "#{sample.name}: #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  # end

  #get_championship_games(teams)

end
