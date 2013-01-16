cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(segmentation)
find_package(PCL 1.7 REQUIRED)
include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})

add_executable (naive.out naiveMode.cpp)
target_link_libraries (naive.out ${PCL_LIBRARIES})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations -w")

add_executable (ransac.out ransac.cpp)
target_link_libraries (ransac.out ${PCL_LIBRARIES})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations -w")
