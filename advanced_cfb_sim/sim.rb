require_relative 'team'

##Assign ratings to teams
blank_teams = Team.create_all
blank_teams.shuffle.each_with_index do |team, idx|
  team.rating = RATINGS[idx]
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
