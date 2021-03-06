import std.stdio, std.random, std.array, std.conv, std.traits,
       std.exception, std.range, std.algorithm;

const class SetDealer {
    protected {
        enum Color:  ubyte {green, purple, red}
        enum Number: ubyte {one, two, three}
        enum Symbol: ubyte {oval, diamond, squiggle}
        enum Fill:   ubyte {open, striped, solid}

        static struct Card {
            Color c;
            Number n;
            Symbol s;
            Fill f;
        }

        static immutable Card[81] deck;
    }

    static this() pure nothrow @safe {
        immutable colors = [EnumMembers!Color];
        immutable numbers = [EnumMembers!Number];
        immutable symbols = [EnumMembers!Symbol];
        immutable fill = [EnumMembers!Fill];

        deck = deck.length.iota.map!(i => Card(colors[i / 27],
                                               numbers[(i / 9) % 3],
                                               symbols[(i / 3) % 3],
                                               fill[i % 3])).array;
    }

    // randomSample produces a sorted output that's convenient in our
    // case because we're printing to stout. Normally you would want
    // to shuffle.
    immutable(Card)[] deal(in uint numCards) const {
        enforce(numCards < deck.length, "Number of cards too large");
        return deck[].randomSample(numCards).array;
    }

    // The summed enums of valid sets are always zero or a multiple
    // of 3.
    bool validSet(in ref Card c1, in ref Card c2, in ref Card c3)
    const pure nothrow @safe @nogc {
        return !((c1.c + c2.c + c3.c) % 3 ||
                 (c1.n + c2.n + c3.n) % 3 ||
                 (c1.s + c2.s + c3.s) % 3 ||
                 (c1.f + c2.f + c3.f) % 3);
    }

    immutable(Card)[3][] findSets(in Card[] cards, in uint target = 0)
    const pure nothrow @safe {
        immutable len = cards.length;
        if (len < 3)
            return null;

        typeof(return) sets;
        foreach (immutable i; 0 .. len - 2)
            foreach (immutable j; i + 1 .. len - 1)
                foreach (immutable k; j + 1 .. len)
                    if (validSet(cards[i], cards[j], cards[k])) {
                        sets ~= [cards[i], cards[j], cards[k]];
                        if (target != 0 && sets.length > target)
                            return null;
                    }
        return sets;
    }
}

const final class SetPuzzleDealer : SetDealer {
    enum {basic = 9, advanced = 12}

    override immutable(Card)[] deal(in uint numCards = basic) const {
        immutable numSets = numCards / 2;
        typeof(return) cards;

        do {
            cards = super.deal(numCards);
        } while (findSets(cards, numSets).length != numSets);

        return cards;
    }
}

void main() {
    const dealer = new SetPuzzleDealer;
    const cards = dealer.deal;

    writefln("DEALT %d CARDS:", cards.length);
    writefln("%(%s\n%)", cards);

    immutable sets = dealer.findSets(cards);
    immutable len = sets.length;
    writefln("\nFOUND %d SET%s:", len, len == 1 ? "" : "S");
    writefln("%(%(%s\n%)\n\n%)", sets);
}
