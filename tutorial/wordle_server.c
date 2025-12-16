#include <stdint.h>
#include <stdbool.h>
#include <microkit.h>
#include <stddef.h>
#include "printf.h"
#include "wordle.h"

/*
 * Here we initialise the word to "hello", but later in the tutorial
 * we will actually randomise the word the user is guessing.
 */
char word[WORD_LENGTH] = { 'h', 'e', 'l', 'l', 'o' };
enum character_state states[WORD_LENGTH] = { INCORRECT };

bool char_in_word(char *word, char ch) {
    for (int i = 0; i < WORD_LENGTH; i++) {
        if (word[i] == ch) {
            return true;
        }
    }

    return false;
}

void calculate_states(char *word, char *guess , enum character_state *states) {
    int counts[26] = { 0 };

    for (int i = 0; i < WORD_LENGTH; i++) {
        counts[word[i] - 'a']++;
    }

    for (int i = 0; i < WORD_LENGTH; i++) {
        if (guess[i] == word[i]) {
            states[i] = CORRECT_PLACEMENT;
            counts[guess[i] - 'a']--;
        } else {
            states[i] = INCORRECT;
        }
    }

    for (int i = 0; i < WORD_LENGTH; i++) {
        if (guess[i] != word[i] && char_in_word(word, guess[i])
            && counts[guess[i] - 'a'] > 0) {
            states[i] = INCORRECT_PLACEMENT;
            counts[guess[i] - 'a']--;
        }
    }
}

void init(void) {
    microkit_dbg_puts("WORDLE SERVER: starting\n");
}

void notified(microkit_channel channel) {}
