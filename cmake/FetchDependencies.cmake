# cmake/FetchDependencies.cmake
include(FetchContent)

# ------------------------
# Eigen
# ------------------------
FetchContent_Declare(
  eigen
  GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
  GIT_TAG 3.4.0
)
FetchContent_MakeAvailable(eigen)

# ------------------------
# OpenCV + contrib
# ------------------------

# 1. Fetch opencv_contrib
FetchContent_Declare(
  opencv_contrib
  GIT_REPOSITORY https://github.com/opencv/opencv_contrib.git
  GIT_TAG 4.10.0
)
FetchContent_GetProperties(opencv_contrib)
if(NOT opencv_contrib_POPULATED)
    FetchContent_Populate(opencv_contrib)
endif()

# 2. 设置 contrib 模块路径
set(OPENCV_EXTRA_MODULES_PATH "${opencv_contrib_SOURCE_DIR}/modules" CACHE PATH "Path to opencv_contrib modules")

# 3. 设置 OpenCV 构建选项，最小化编译
set(OPENCV_SKIP_PYTHON ON)
set(BUILD_opencv_python_bindings_generator OFF)
set(BUILD_TESTS OFF)
set(BUILD_DOCS OFF)
set(BUILD_EXAMPLES OFF)
set(BUILD_PERF_TESTS OFF)
set(BUILD_JAVA OFF)
set(BUILD_ANDROID_EXAMPLES OFF)

# 4. Fetch opencv
FetchContent_Declare(
  opencv
  GIT_REPOSITORY https://github.com/opencv/opencv.git
  GIT_TAG 4.10.0
)
FetchContent_MakeAvailable(opencv)

# ------------------------
# Ceres Solver
# ------------------------
FetchContent_Declare(
  ceres
  GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver.git
  GIT_TAG 2.2.0
)
FetchContent_MakeAvailable(ceres)
