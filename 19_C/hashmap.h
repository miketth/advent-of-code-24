//
// Created by mike on 20/12/24.
//

#ifndef HASHMAP_H
#define HASHMAP_H

#define BUCKET_SIZE 1024

typedef struct bucket {
    const char* key;
    long int value;
    struct bucket* next;
} bucket;

typedef struct hashmap {
    bucket* buckets[BUCKET_SIZE];
} hashmap;

hashmap new_hashmap();
void release_map(hashmap* map);
void add(hashmap* map, const char* key, long int val);
long int get(const hashmap* map, const char* key);

#endif //HASHMAP_H
