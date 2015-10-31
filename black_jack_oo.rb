
class Card
  attr_accessor :suite, :face_value, :value

  def initialize(suite, face_value, value)
    @suite = suite
    @face_value = face_value
    @value = value
  end

end

class Deck
  attr_reader :cards

  def initialize(deck_number)
    face_values = %w(2 3 4 5 6 7 8 9 10 J K Q A)
    suites = %w(Spade Heart Diamond Club)
    @cards = []
    deck_number.times do
      face_values.each do |num|
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
  attr_reader :cards

  def initialize(*card)
    @cards = []
    cards << card
    cards.flatten!
  end

  def to_s
    display = ''
    cards.each do |card|
      display << "'#{card.suite} #{card.face_value}' "
    end
    display.strip
  end

  def show_one
    "'#{cards[0].suite} #{cards[0].face_value}'"
  end

  def hit(deck)
    cards << deck.cards.pop
  end

  def calculate_hand_values
    hand_values = []
    cards.each do |card|
      hand_values << card.value
    end
    hand_values.inject(:+)
  end

  def total
    # if hand includes an 11 and is over 21, change the value of 11 to 1
    cards.each do |card|
      if card.value == 11 && calculate_hand_values > 21
        card.value = 1
      end
    end
    calculate_hand_values
  end

end

class Person
  attr_accessor :name, :role
  attr_reader :hand

  def initialize(hand, role, name = nil)
    @hand = hand
    @role = role
    @name = name
  end

  def print_hand
    puts "#{name}'s hand is #{hand}. #{name}'s total is #{hand.total}."
  end

  def blackjack?
    hand.total == 21
  end

  def play_hand(deck)
    role == 'player' ? player_turn(deck) : dealer_turn(deck)
  end

  def display_blackjack
    blackjack? ? display_blackjack = 'Blackjack!' : display_blackjack = ''
    display_blackjack
  end

  def player_turn(deck)
    while hand.total < 21
      puts 'Do you want to hit or stay?'
      action = gets.chomp
      unless %w(h s).include?(action)
        puts 'You did not enter h or s'
        next
      end
      if action == 'h'
        hand.hit(deck)
        puts "#{name} your hand is #{hand}. Your total is #{hand.total}. #{display_blackjack}"
      else
        puts 'You chose to stay.'
        puts ''
        break
      end
      if hand.total > 21
        puts "#{name} you busted."
        exit
      end
    end

  end

  def dealer_turn(deck)
    while hand.total < 17
      puts "#{name} hits."
      hand.hit(deck)
      puts "#{name}'s hand is now #{hand}. Total is: #{hand.total}. #{display_blackjack}"
      if hand.total > 21
        puts "#{name} busted."
      end
    end
  end

end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    self.deck = Deck.new(2)
    self.player = Person.new(deck.deal_hand, 'player')
    self.dealer = Person.new(deck.deal_hand, 'dealer', 'Dealer')
  end

  def both_players_have_blackjack?
    player.hand.total == 21 && dealer.hand.total == 21
  end

  def get_name
    puts 'Please enter your name:'
    player.name = gets.chomp
  end

  def display_hands
    player.print_hand
    puts ''
    puts "Dealer's first card is #{dealer.hand.show_one}."
    puts ''
  end

  def compare_hands
    case
      when dealer.hand.total > 21
        puts "#{player.name} you win!"
        exit
      when both_players_have_blackjack? || player.hand.total == dealer.hand.total
        puts "It's a tie."
      when player.blackjack?
        puts "Blackjack! #{player.name} you win!"
      when dealer.blackjack?
        puts "Blackjack! #{dealer.name} wins!"
      else
        player.hand.total > dealer.hand.total ? puts("#{player.name} you win!") : puts("#{dealer.name} wins!")
    end
  end

  def run
    get_name
    display_hands
    if both_players_have_blackjack?
      dealer.print_hand
      puts "#{player.name} and #{dealer.name}  both have Blackjack!  It's a tie."
    else
      player.play_hand(deck)
      dealer.print_hand
      dealer.play_hand(deck)
    end
    compare_hands
  end
end

Game.new.run
