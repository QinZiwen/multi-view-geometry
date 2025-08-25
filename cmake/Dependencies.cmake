# cmake/Dependencies.cmake
include(FetchContent)
include(ExternalProject)

set(DEPS_INSTALL_DIR ${CMAKE_BINARY_DIR}/deps)
set(DEPS_INCLUDE_DIR ${DEPS_INSTALL_DIR}/include)
set(DEPS_LIB_DIR ${DEPS_INSTALL_DIR}/lib)

# ------------------------ Eigen (header-only) ------------------------
FetchContent_Declare(
  eigen
  GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
  GIT_TAG 3.4.0
)
FetchContent_MakeAvailable(eigen)

# 复制 Eigen 头文件到 deps/include/eigen3
file(COPY ${eigen_SOURCE_DIR}/Eigen DESTINATION ${DEPS_INCLUDE_DIR}/eigen3)

# ------------------------ gflags ------------------------
ExternalProject_Add(ext_gflags
    GIT_REPOSITORY https://github.com/gflags/gflags.git
    GIT_TAG v2.2.2
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${DEPS_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
)
add_library(gflags_lib STATIC IMPORTED GLOBAL)
set_target_properties(gflags_lib PROPERTIES
    IMPORTED_LOCATION ${DEPS_LIB_DIR}/libgflags.a
    INTERFACE_INCLUDE_DIRECTORIES ${DEPS_INCLUDE_DIR}
)
add_dependencies(gflags_lib ext_gflags)

# ------------------------ glog ------------------------
ExternalProject_Add(ext_glog
    GIT_REPOSITORY https://github.com/google/glog.git
    GIT_TAG v0.6.0
    DEPENDS ext_gflags
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${DEPS_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DWITH_GFLAGS=ON
        -DBUILD_TESTING=OFF
        -DWITH_GTEST=OFF
        -DGFLAGS_INCLUDE_DIR=${DEPS_INCLUDE_DIR}
        -DGFLAGS_LIBRARY=${DEPS_LIB_DIR}/libgflags.a
)
add_library(glog_lib STATIC IMPORTED GLOBAL)
set_target_properties(glog_lib PROPERTIES
    IMPORTED_LOCATION ${DEPS_LIB_DIR}/libglog.a
    INTERFACE_INCLUDE_DIRECTORIES ${DEPS_INCLUDE_DIR}
)
add_dependencies(glog_lib ext_glog)

# ------------------------ Ceres ------------------------
ExternalProject_Add(ext_ceres
    GIT_REPOSITORY https://ceres-solver.googlesource.com/ceres-solver
    GIT_TAG 2.2.0
    DEPENDS ext_gflags ext_glog
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${DEPS_INSTALL_DIR}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_BENCHMARKS=OFF
        -DMINIGLOG=OFF
        -DGLOG_INCLUDE_DIR=${DEPS_INCLUDE_DIR}
        -DGLOG_LIBRARY=${DEPS_LIB_DIR}/libglog.a
        -DGFLAGS_INCLUDE_DIR=${DEPS_INCLUDE_DIR}
        -DGFLAGS_LIBRARY=${DEPS_LIB_DIR}/libgflags.a
        -DEigen3_DIR=${DEPS_INCLUDE_DIR}/eigen3
)
add_library(ceres_lib STATIC IMPORTED GLOBAL)
set_target_properties(ceres_lib PROPERTIES
    IMPORTED_LOCATION ${DEPS_LIB_DIR}/libceres.a
    INTERFACE_INCLUDE_DIRECTORIES ${DEPS_INCLUDE_DIR}
)
add_dependencies(ceres_lib ext_ceres gflags_lib glog_lib Eigen3::Eigen)

# ------------------------ 汇总 INTERFACE target ------------------------
add_library(deps INTERFACE)
target_link_libraries(deps INTERFACE gflags_lib glog_lib ceres_lib Eigen3::Eigen)
