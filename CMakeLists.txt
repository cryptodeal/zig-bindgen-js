cmake_minimum_required(VERSION 3.10)

project(shumai LANGUAGES CXX C)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(flashlight CONFIG REQUIRED)

# Flashlight <> JS bindings
add_library(
  flashlight_binding
  SHARED
  cpp/flashlight_binding.cc
  )

target_link_libraries(
  flashlight_binding
  PRIVATE
  flashlight::flashlight
)

install(TARGETS flashlight_binding)