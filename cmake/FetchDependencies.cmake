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

# 下载并让它们可用
FetchContent_MakeAvailable(opencv_contrib)

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

# 下载 gflags（可选，glog 推荐配合使用）
set(GFLAGS_NAMESPACE gflags CACHE STRING "Namespace for gflags" FORCE)
message(STATUS "GFLAGS_NAMESPACE = ${GFLAGS_NAMESPACE}")
FetchContent_Declare(
  gflags
  GIT_REPOSITORY https://github.com/gflags/gflags.git
  GIT_TAG        v2.2.2
)
FetchContent_MakeAvailable(gflags)

# 下载 glog
FetchContent_Declare(
  glog
  GIT_REPOSITORY https://github.com/google/glog.git
  GIT_TAG        v0.6.0
)

set(WITH_GFLAGS ON CACHE BOOL "Build glog with gflags")
set(gflags_DIR "${gflags_BINARY_DIR}" CACHE PATH "Path to gflags build dir")

FetchContent_MakeAvailable(glog)

# ------------------------
# Ceres Solver
# ------------------------
FetchContent_Declare(
  ceres
  GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver.git
  GIT_TAG 2.2.0
)

set(gflags_DIR "${gflags_BINARY_DIR}" CACHE PATH "Path to gflags build dir" FORCE)
set(glog_DIR   "${glog_BINARY_DIR}"   CACHE PATH "Path to glog build dir" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "Disable ceres tests")
set(BUILD_EXAMPLES OFF CACHE BOOL "Disable ceres examples")

message(STATUS "gflags_DIR: ${gflags_DIR}")
message(STATUS "glog_DIR: ${glog_DIR}")
find_package(gflags CONFIG REQUIRED)
find_package(glog CONFIG REQUIRED)

set_property(GLOBAL PROPERTY TARGET_MESSAGES OFF) # 安静点
set(SKIP_CERES_UNINSTALL ON CACHE BOOL "Skip uninstall target in Ceres")

FetchContent_MakeAvailable(ceres)
