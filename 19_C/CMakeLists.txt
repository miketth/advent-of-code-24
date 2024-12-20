cmake_minimum_required(VERSION 3.30)
project(19_C C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
set(CMAKE_C_STANDARD 23)

add_executable(19_C
        main.c
        hashmap.c
        hashmap.h
)
