require_relative 'team'
require_relative 'scheduler'
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

def champ_sim(team1, team2)
  champ = sim_game(team1, team2, true)
  puts "#{champ} wins their conference championship!"
  champ.conf_champ += 1
end

def get_playoff_teams(teams, spots = 4)
  ranked = ranker(teams)
  ranked_list(ranked, 25)
  ranked.take(spots)
end



if __FILE__ == $0
  best_team_wins = 0
  best_made_playoffs = 0
  undefeateds = 0
  conferences_represented = 0
  all_different = 0
  1000000.times do
    teams = Team.create_all
    results = run_season(teams)
    best_team_wins += 1 if results[0].true_rank == 1
    best_made_playoffs += 1 if results[1]
    undefeateds += results[2]
    conferences_represented += results[3]
    all_different += 1 if results[4]
  end

  puts "Best team won #{best_team_wins} times out of a million."
  puts "Best team made playoffs #{best_made_playoffs} times."
  puts "There were an average of #{undefeateds / 1000000.0} undefeated regular season teams."
  puts "There were an average of #{conferences_represented / 1000000.0} conferences in the playoffs."
  puts "Four different conferences were represented #{all_different} times."
  # 5.times do
  #   sample = teams.sample
  #   puts "#{sample.name}: #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  # end

  #get_championship_games(teams)

end
