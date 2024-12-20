//
// Created by mike on 20/12/24.
//

#include "hashmap.h"

#include <stdlib.h>
#include <string.h>

hashmap new_hashmap() {
    hashmap h;
    for (int i = 0; i < BUCKET_SIZE; i++) {
        h.buckets[i] = nullptr;
    }
    return h;
}

void release_bucket(bucket* b) {
    if (b->next != nullptr) {
        release_bucket(b->next);
    }

    free((void*) b->key);
    free(b);
}

void release_map(hashmap* map) {
    for (int i = 0; i < BUCKET_SIZE; i++) {
        auto b = map->buckets[i];
        if (b != nullptr) {
            release_bucket(b);
            map->buckets[i] = nullptr;
        }
    }
}

int hash_key(const char* key) {
    int hash = 0;
    for (int i = 0; i < strlen(key); i++) {
        hash += key[i];
        hash %= BUCKET_SIZE;
    }
    return hash;
}

void add(hashmap* map, const char* key, const long int val) {
    char* key_copy = malloc((strlen(key)+1)*sizeof(char));
    strcpy(key_copy, key);


    bucket* entry = malloc(sizeof(bucket));
    entry->key = key_copy;
    entry->value = val;

    const auto hash = hash_key(key_copy);

    bucket* b = map->buckets[hash];
    entry->next = b;
    map->buckets[hash] = entry;
}

long int get(const hashmap* map, const char* key) {
    auto b = map->buckets[hash_key(key)];
    if (b == nullptr) {
        return -1;
    }
    while (strcmp(b->key, key) != 0) {
        if (b->next == nullptr) {
            return -1;
        }

        b = b->next;
    }
    return b->value;
}
