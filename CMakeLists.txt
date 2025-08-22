cmake_minimum_required(VERSION 3.16)
project(MultiViewGeometry LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# === 引入依赖 ===
include(cmake/FetchDependencies.cmake)

# === 核心库 ===
add_library(mvgeom_core
    src/core/eight_point.cpp
)
target_include_directories(mvgeom_core PUBLIC src/core)
target_link_libraries(mvgeom_core PUBLIC Eigen3::Eigen opencv_core opencv_imgproc opencv_highgui ceres)

# === apps ===
add_executable(eight_point apps/eight_point/eight_point.cpp)
target_link_libraries(eight_point PRIVATE mvgeom_core)
