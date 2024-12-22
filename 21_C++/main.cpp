#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

using std::string;
using std::string_view;
using std::vector;
using std::shared_ptr;

vector<string> read_file(const string& filename) {
    auto file = std::ifstream(filename);
    if (!file) {
        throw std::runtime_error("Couldn't open file");
    }

    vector<string> lines;
    string line;
    while (std::getline(file, line)) {
        lines.push_back(line);
    }

    file.close();
    return lines;
}

const std::vector<std::vector<char>> numpad = {
    { '7', '8', '9' },
    { '4', '5', '6' },
    { '1', '2', '3' },
    { '\0', '0', 'A' }
};

const std::vector<std::vector<char>> dirpad = {
    { '\0', '^', 'A' },
    { '<', 'v', '>' },
};

[[nodiscard]] std::pair<int, int> keypad_idx(const vector<vector<char>>& keypad, const char& c) {
    for (int y = 0; y < keypad.size(); y++) {
        for (int x = 0; x < keypad[y].size(); x++) {
            if (keypad[y][x] == c) {
                return { x, y };
            }
        }
    }

    throw std::runtime_error("keypad key not found");
}

typedef std::pair<char, char> KeypadCacheKey;

string_view best_path(const char& from, const char& to, std::map<KeypadCacheKey, string>& cache, const bool is_numpad = false) {
    const KeypadCacheKey cache_key = { from, to };
    if (cache.contains(cache_key)) {
        return cache[cache_key];
    }

    auto keypad_p = &dirpad;
    if (is_numpad) {
        keypad_p = &numpad;
    }

    const auto& keypad = *keypad_p;

    const auto [from_x, from_y] = keypad_idx(keypad, from);
    const auto [to_x, to_y] = keypad_idx(keypad, to);

    const auto x_diff = to_x - from_x;
    const auto y_diff = to_y - from_y;

    auto horiz_char = '>';
    if (x_diff < 0) {
        horiz_char = '<';
    }
    const auto horizontal = string(abs(x_diff), horiz_char);

    auto vert_char = 'v';
    if (y_diff < 0) {
        vert_char = '^';
    }
    const auto vertical = string(abs(y_diff), vert_char);


    if (x_diff == 0 || y_diff == 0) {
        cache[cache_key] = horizontal + vertical;
        return cache[cache_key];
    }

    // if horizontal->vertical isn't possible
    if (keypad[from_y][to_x] == '\0') {
        cache[cache_key] = vertical + horizontal;
        return cache[cache_key];
    }

    // if vertical->horizontal isn't possible
    if (keypad[to_y][from_x] == '\0') {
        cache[cache_key] = horizontal + vertical;
        return cache[cache_key];
    }

    // if left: horiz->vert is better
    if (x_diff < 0) {
        cache[cache_key] = horizontal + vertical;
        return cache[cache_key];
    }

    // if right: vert->horiz is better
    cache[cache_key] = vertical + horizontal;
    return cache[cache_key];
}

string best_path(const string& combination, std::map<KeypadCacheKey, string>& cache, const bool is_numpad = false) {
    string ret;
    char prev = 'A';
    for (const auto& next: combination) {
        auto path_here = best_path(prev, next, cache, is_numpad);
        ret += path_here;
        ret += 'A';
        prev = next;
    }

    return ret;
}

vector<char> states_lower_or_equal_depth(vector<char>& states, const int depth) {
    return {states.begin()+depth, states.end()};
}

// depth, lower states, combination
typedef std::tuple<int, vector<char>, string> SimCacheKey;
// saved states, return
typedef std::tuple<vector<char>, unsigned long long int> SimCacheVal;

unsigned long long int simulate_dirpad(
    const string_view& combination,
    std::map<SimCacheKey, SimCacheVal>& cache,
    std::map<KeypadCacheKey, string>& keypad_cache,
    vector<char>& states,
    const int max_depth, const int depth = 1
) {
    const auto cache_key = SimCacheKey(depth, states_lower_or_equal_depth(states, depth), combination);
    if (cache.contains(cache_key)) {
        const auto& [cached_states, len] = cache[cache_key];
        for (int i = 0; i < cached_states.size(); i++) {
            states[i+depth] = cached_states[i];
        }
        return len;
    }

    unsigned long long int ret = 0;

    char& prev = states[depth];

    for (const auto& next: combination) {
        auto path_here = best_path(prev, next, keypad_cache, false);
        if (depth == max_depth) {
            ret += path_here.length();
            ret++; // for the 'A'
        } else {
            const auto one_layer_down = simulate_dirpad(path_here, cache, keypad_cache, states, max_depth, depth+1);
            ret += one_layer_down;
            const auto one_layer_down_a = simulate_dirpad("A", cache, keypad_cache, states, max_depth, depth+1);
            ret += one_layer_down_a;
        }
        prev = next;
    }

    cache[cache_key] = SimCacheVal(states_lower_or_equal_depth(states, depth), ret);

    return ret;
}


// const string filename = "input_sample.txt";
const string filename = "input.txt";

int main() {
    const auto codes = read_file(filename);

    unsigned long int sum = 0;

    std::map<KeypadCacheKey, string> numpad_cache;
    std::map<KeypadCacheKey, string> dirpad_cache;
    std::map<SimCacheKey, SimCacheVal> sim_cache;
    for (const auto& code: codes) {
        std::cout << "solving code " << code << std::endl;

        vector<string> final_paths;

        auto path = best_path(code, numpad_cache, true);

        constexpr int depth = 25;
        auto states = vector(depth+1, 'A');
        const auto len = simulate_dirpad(path, sim_cache, dirpad_cache, states, depth);

        sum += len * stoi(code);
    }

    std::cout << sum << std::endl;

    return 0;
}