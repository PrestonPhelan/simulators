require_relative 'team'

##Non-Conference Schedule
  ##Each team gets a random game against another non-conference P5 school

  acc = TEAMS[:ACC][:Atlantic] + TEAMS[:ACC][:Coastal]
  big_12 = TEAMS[:Big_12].map { |el| el }
  big_ten = TEAMS[:Big_Ten][:East] + TEAMS[:Big_Ten][:West]
  pac12 = TEAMS[:PAC_12][:North] + TEAMS[:PAC_12][:South]
  sec = TEAMS[:SEC][:East] + TEAMS[:SEC][:West]

  print acc.length
  puts
  print big_12
  puts
  print big_ten
  puts
  print pac12
  puts
  print sec

  ##Each team gets a two home games agains G5 schools
  #G5_TEAMS.shuffle.take(2)

##Conference Schedule, CONSTANT sim-to-sim
  ##14-team conferences: 6 division games, 3 other division
  ##Pac-12: 5 division game, 4 other division
  ##Big 12: Every other team round robin
