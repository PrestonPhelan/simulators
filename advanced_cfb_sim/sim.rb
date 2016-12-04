require_relative 'team'
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
  # sim_game(home, away)
    ##Determine if away is team or just rating
    ##Determine winner
      ##Norm Dist (home_rating + 3 - away_rating, STDDEV)
      ##If rand(x) > y, home, away
    ##Update W-L
      #if conference
        #winner.add_conference_win
        #loser.add_conference_loss
      #else
        #winner.add_win
        #loser.add_loss
  # end
