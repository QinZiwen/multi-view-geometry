include(FetchContent)

# === Eigen ===
FetchContent_Declare(
  eigen
  GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
  GIT_TAG 3.4.0
)
FetchContent_MakeAvailable(eigen)

# === OpenCV ===
FetchContent_Declare(
  opencv
  GIT_REPOSITORY https://github.com/opencv/opencv.git
  GIT_TAG 4.10.0
)
FetchContent_MakeAvailable(opencv)

# === Ceres Solver ===
FetchContent_Declare(
  ceres
  GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver.git
  GIT_TAG 2.2.0
)
FetchContent_MakeAvailable(ceres)
