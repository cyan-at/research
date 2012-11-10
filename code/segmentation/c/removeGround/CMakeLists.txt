cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(removeGround)

find_package(PCL 1.7 REQUIRED)

include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})
set(CMAKE_CXX_FLAGS "-Wall -w")
add_executable (removeGround removeGround.cpp)
target_link_libraries (removeGround ${PCL_LIBRARIES})
