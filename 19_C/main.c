#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hashmap.h"

typedef struct string_list {
    char** strings;
    int length;
} string_list;

void release_string_list(string_list* list) {
    for (int i = 0; i < list->length; i++) {
        free(list->strings[i]);
    }

    free(list->strings);

    list->strings = nullptr;
    list->length = 0;
}

typedef struct processed_file {
    string_list available_patterns;
    string_list designs;
    char* error_message;
} processed_file;

string_list process_available_patterns(FILE* file) {
    char* line = nullptr;
    size_t len = 0;
    const ssize_t read = getline(&line, &len, file);

    int num_patterns = 0;
    char** patterns = nullptr;

    char* current = nullptr;
    int curr_size = 0;
    for (int i = 0; i < read; i++) {
        const auto curr = line[i];
        if (curr == ',' || curr == '\n') {
            current[curr_size] = '\0';

            num_patterns++;
            patterns = realloc(patterns, num_patterns*sizeof(char*));
            patterns[num_patterns-1] = current;
            current = nullptr;
            curr_size = 0;
            i++; // skip space
            continue;
        }

        curr_size++;
        current = realloc(current, (curr_size+1)*sizeof(char));
        current[curr_size-1] = curr;
    }

    if (current != nullptr) {
        patterns[num_patterns] = current;
        num_patterns++;
    }

    free(line);

    const string_list list = { patterns, num_patterns };
    return list;
}

void drop_line(FILE* file) {
    char *line = nullptr;
    size_t len = 0;
    getline(&line, &len, file);
    free(line);
}

string_list process_needed_patterns(FILE* file) {
    int num_patterns = 0;
    char** patterns = nullptr;

    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    while ((read = getline(&line, &len, file)) != EOF) {
        if (line[0] == '\n') {
            continue;
        }

        if (line[read-1] == '\n') {
            line[read-1] = '\0';
        }

        char* line_copy = malloc(read * sizeof(char));
        strcpy(line_copy, line);
        num_patterns++;
        patterns = realloc(patterns, num_patterns*sizeof(char*));
        patterns[num_patterns-1] = line_copy;
    }

    free(line);

    const string_list list = { patterns, num_patterns };
    return list;
}

processed_file read_file(const char *file_name) {
    FILE *file = fopen(file_name, "r");
    if (file == NULL) {
        processed_file err;
        err.error_message = "Couldn't open file";
        return err;
    }


    const auto available_patterns = process_available_patterns(file);
    drop_line(file);
    const auto needed_patterns = process_needed_patterns(file);

    fclose(file);

    processed_file ret = { available_patterns, needed_patterns, "" };
    return ret;
}

bool has_prefix(const char* string, const char* prefix) {
    size_t len_string = strlen(string);
    size_t len_prefix = strlen(prefix);

    if (len_prefix > len_string) {
        return false;
    }

    for (size_t i = 0; i < len_prefix; i++) {
        if (string[i] != prefix[i]) {
            return false;
        }
    }
    return true;
}

long int possible_arrangements(const char* design, const string_list available, hashmap* cache) {
    const auto cached = get(cache, design);
    if (cached != -1) {
        return cached;
    }

    long int possibilities = 0;
    for (int i = 0; i < available.length; i++) {
        const auto pattern = available.strings[i];
        if (!has_prefix(design, pattern)) {
            continue;
        }

        const auto remaining_design = design + strlen(pattern);
        if (strlen(remaining_design) == 0) {
            possibilities++;
            continue;
        }
        possibilities += possible_arrangements(remaining_design, available, cache);
    }

    add(cache, design, possibilities);

    return possibilities;
}

void solve(const processed_file data) {
    auto cache = new_hashmap();

    int part_1 = 0;
    long int part_2 = 0;
    for (int i = 0; i < data.designs.length; i++) {
        const auto design = data.designs.strings[i];
        const auto possibilities = possible_arrangements(design, data.available_patterns, &cache);
        if (possibilities != 0) {
            part_1++;
            part_2 += possibilities;
        }
    }

    printf("%d\n%ld\n", part_1, part_2);

    release_map(&cache);
}

// const char* file_name = "input_sample.txt";
const char* file_name = "input.txt";

int main(void) {
    auto data = read_file(file_name);

    solve(data);

    release_string_list(&data.available_patterns);
    release_string_list(&data.designs);
    return 0;
}