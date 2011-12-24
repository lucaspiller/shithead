class Card
  RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
  SUITS = %w(Spade Heart Club Diamond)

  attr_accessor :rank, :suit, :id

  def initialize(id)
    self.id = id
    self.rank = RANKS[id % 13]
    self.suit = SUITS[(id / 13).floor]
  end

  def to_s
    "#{self.rank} of #{self.suit}s"
  end

  def <=>(other)
    id <=> other.id
  end
end

class Deck < Array
  def initialize
    # shuffle array and init each Card
    (0..51).to_a.shuffle.each do |id|
      self << Card.new(id)
    end
  end
end
