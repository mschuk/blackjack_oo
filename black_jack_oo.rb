
class Card
  attr_accessor :suite, :value, :num

  def initialize(suite, num, value)
    @suite = suite
    @num = num
    @value = value
  end

end

class Deck
  attr_accessor :cards

  def initialize(deck_number)
    numbers = %w(2 3 4 5 6 7 8 9 10 J K Q A)
    suites = %w(Spade Heart Diamond Club)
    @cards = []
    deck_number.times do
      numbers.each do |num|
        suites.each do |suite|
          if %w(J K Q).include?(num)
            cards << Card.new(suite, num, 10)
          elsif num == 'A'
            cards << Card.new(suite, num, 11)
          else
            cards << Card.new(suite, num, num.to_i)
          end
        end
      end
    end
    self.cards.shuffle!
  end

  def deal_hand
    Hand.new(cards.pop, cards.pop)
  end

end

class Hand
  attr_accessor :hand

  def initialize(*card)
    @hand = []
    hand << card
    hand.flatten!
  end

  def to_s
    display = ''
    hand.each do |card|
      display << "'#{card.suite} #{card.num}' "
    end
    display
  end

  def show_one
    "'#{hand[0].suite} #{hand[0].num}'"
  end

  def hit(deck)
    hand << deck.cards.pop
  end

  def calculate_hand_values
    hand_values = []
    hand.each do |card|
      hand_values << card.value
    end
    hand_values.inject(:+)
  end

  def total
    # if hand includes an 11 and is over 22, change the value of 11 to 1
    hand.each do |card|
      if card.value == 11 && calculate_hand_values > 22
        card.value = 1
      end
    end
    calculate_hand_values
  end

end

class Person
  attr_accessor :name, :hand

  def initialize(hand, name = nil)
    @hand = hand
    @name = name
  end

  def print_hand
    puts "#{name}'s hand is #{hand}"
    puts "#{name}'s total is #{hand.total}"
  end

  def blackjack?
    hand.total == 21
  end

end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    self.deck = Deck.new(2)
    self.player = Person.new(deck.deal_hand)
    self.dealer = Person.new(deck.deal_hand, 'Dealer')
  end

  def blackjack_tie?
    player.hand.total == 21 && dealer.hand.total == 21
  end

  def get_name
    puts "Please enter your name:"
    name = gets.chomp
    player.name = name
  end

  def output_deal
    get_name
    player.print_hand
    puts ''
    puts "Dealer's first card is #{dealer.hand.show_one}"
  end

  def players_turn
    while player.hand.total < 21
      puts 'Do you want to hit or stay?'
      action = gets.chomp
      unless %w(h s).include?(action)
        puts 'You did not enter h or s'
        next
      end
      if action == 'h'
        player.hand.hit(deck)
        puts "#{player.name} your hand is #{player.hand}."
        puts "Your total is #{player.hand.total}."
      else
        puts 'You chose to stay.'
        break
      end
      if player.hand.total > 21
        puts "#{player.name} you busted."
        exit
      end
    end
  end

  def dealers_turn
    while dealer.hand.total < 17
      puts "#{dealer.name} hits."
      dealer.hand.hit(deck)
      puts "#{dealer.name}'s hand is now #{dealer.hand}."
      puts "Total is: #{dealer.hand.total}"
      if dealer.hand.total > 21
        puts "#{dealer.name} busted, you win!"
        exit
      end
    end
  end

  def compare_hands
    if player.hand.total > dealer.hand.total
      puts "#{player.name} you win!"
    else
      puts "#{dealer.name} wins!"
    end
  end

  def run
    output_deal

    # check to see if both hands have 21
    if blackjack_tie?
      dealer.print_hand
      puts "It's a tie!"
    else
      players_turn
      dealer.print_hand
      dealers_turn

      # after dealers turn, check again if both hands are 21
      if blackjack_tie?
        puts "It's a tie."
        exit
      end

      if player.blackjack?
        puts "#{player.name} you win!"
        exit
      end

      compare_hands
    end
  end
end

Game.new.run
