require_relative 'team'
require_relative 'scheduler'
require 'byebug'

##DEFINE RATINGS CONSTANTS

##Assign ratings to teams
def assign_ratings(teams = Team.create_all)
  teams.shuffle.each_with_index do |team, idx|
    team.rating = RATINGS[idx]
  end

  teams
end

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

##Run G5 games
  # TEAMS.each do |team|
  #   2.times do
  #     opp_rating = G5_RATINGS.sample
  #     sim_game(team, opponent)
  #   end
  # end

##Generate P5 Matchups, Run

##Generate conference game list, Run

##Play all games


### HELPER METHODS


##Game simulator
def sim_game(home, away)
    #Determine if away is team or just rating
  winner = rand(2) == 1 ? home : away
  loser = winner == home ? away : home

  if away.is_a?(Team)
    if winner.conference == loser.conference
      winner.add_conference_win
      loser.add_conference_loss
    else
      winner.add_win
      loser.add_loss
    end
  else
    winner == home ? winner.add_win : loser.add_loss
  end

  puts "#{winner} over #{loser}"

  #Determine winner
    #Norm Dist (home_rating + 3 - away_rating, STDDEV)
    #If rand(x) > y, home, away
  #Update W-L
    # if conference
    #   winner.add_conference_win
    #   loser.add_conference_loss
    # else
    #   winner.add_win
    #   loser.add_loss
end

def run_season(teams = Team.create_all)
  games = generate_full_schedule(teams)

  games.shuffle.each { |game| sim_game(game[0], game[1]) }
end

def ranker(teams)
  teams.sort { |x, y| x.losses <=> y.losses }
end

if __FILE__ == $0
  teams = Team.create_all
  run_season(teams)
  # 5.times do
  #   sample = teams.sample
  #   puts "#{sample.name}: #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  # end

  puts "Top 10"
  puts "******"
  ranked = ranker(teams)
  10.times do |i|
    sample = ranked[i]
    puts "\##{i + 1} #{sample.name} #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  end
end
