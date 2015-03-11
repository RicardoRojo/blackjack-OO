class Deck
  SUITS = ["Hearts","Spades","Clubs","Diamonds"]
  CARD_VALUE = [2,3,4,5,6,7,8,9,10,"A","J","Q","K"]

  def initialize
    @playing_deck = []
    SUITS.each do |suit|
      CARD_VALUE.each do |face|
        @playing_deck << Card.new(suit,face)
      end
    end
    shuffle_deck!
  end 

  def shuffle_deck!
    3.times{ @playing_deck.shuffle!}
  end

  def deal_card
    @playing_deck.pop
  end
end

class Card
  attr_reader :suit, :face_value

  def initialize(suit, face_value)
    @suit = suit
    @face_value = face_value
  end

  def draw_card
    puts "==============="
    puts "#{suit}".center(15)
    puts "#{face_value}".center(15)
    puts "==============="
  end

  def draw_hidden_card
    puts "==============="
    puts "???".center(15)
    puts "???".center(15)
    puts "==============="
  end
end

module Handable
  def total_sum
    total = 0
    aces = 0
    @hand.each do |card|
      if card.face_value == "A"
        aces += 1
        total += 1
      elsif card.face_value.to_i == 0
        total += 10
      else
        total += card.face_value
      end
    end
    if aces > 0 && total + 10 <= 21
      total += 10
    end
    total
  end

  def add_card(card)
    @hand << card
  end

  def is_busted?
    total_sum > 21
  end

  def win?
    total_sum == 21
  end

  def show_full_hand
    puts "---#{name}´s hand---"
    @hand.each do |card|
      card.draw_card
    end
    puts "The total sum of #{name} is #{total_sum}"
  end

end

class Player
  include Handable
  attr_reader :name

  def initialize(name)
    @name = name
    @hand = []
  end

  def show_first_hand
    show_full_hand
  end

end

class Dealer
  include Handable
  attr_reader :name

  def initialize
    @name = "Dealer"
    @hand = []
  end

  def show_first_hand
    puts "---#{name}´s hand---"
    @hand.first.draw_card
    @hand.last.draw_hidden_card
    puts "The total sum of #{name} is unknown"
  end
  def has_17_or_more?
    total_sum >= 17
  end
end


class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new("Bob")
    @dealer = Dealer.new
  end

  def play
    give_first_hand
    system('clear')
    show_hand_player
    show_first_hand_dealer
    player_plays
    dealer_plays
    compare_hands
  end

  def give_first_hand
    player.add_card(deck.deal_card)
    player.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
    dealer.add_card(deck.deal_card)
  end

  def show_hand_player
    player.show_full_hand
  end

  def show_hand_dealer
    dealer.show_full_hand
  end

  def show_first_hand_dealer
    dealer.show_first_hand
  end

  def show_both_hands
    system('clear')
    show_hand_player
    show_hand_dealer
  end

  def player_plays
    if player.win?
      puts "#{player.name} Wins!!"
      exit
    end

    begin
      choice = hit_or_stay
      if choice == "H"
        player.add_card(deck.deal_card)
        show_both_hands
      end
    end until ["S"].include?(choice) || player.win? || player.is_busted?
      if player.win?
        puts "#{player.name} Wins!!"
        exit
      elsif player.is_busted?
        puts "#{player.name} is Busted!!"
        exit
      end
  end

  def hit_or_stay
    begin
      puts "Hit or Stay (H/S)?"
      choice = gets.chomp.upcase
    end until ["S","H"].include?(choice)
    choice
  end

  def dealer_plays
    if dealer.win?
      puts "#{player.name} Wins!!"
      show_both_hands
      exit
    end
    while !dealer.has_17_or_more? do
      dealer.add_card(deck.deal_card)
    end
    show_both_hands
    if dealer.win?
      puts "Dealer Wins!!"
      exit
    elsif dealer.is_busted?
      puts "Dealer is Busted. #{player.name} Wins!!"
      exit
    end
  end
  
  def compare_hands
    if player.total_sum > dealer.total_sum
      puts "#{player.name} Wins!!" 
    elsif player.total_sum < dealer.total_sum
      puts "Dealer Wins!!"
    else
      puts "It´s a Tie!!"
    end
  end
end
Game.new.play