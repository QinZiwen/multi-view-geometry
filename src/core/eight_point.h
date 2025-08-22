#pragma once

#include <Eigen/Core>
#include <vector>
#include <utility>

namespace mvgeom {

// ---------------------------
// 数据结构
// ---------------------------

// 点对 (x1, y1) ↔ (x2, y2)
struct Match2D2D {
    Eigen::Vector2d p1;
    Eigen::Vector2d p2;
};

// ---------------------------
// 函数接口
// ---------------------------

/**
 * @brief 对二维点集进行归一化（均值为零，平均距离为 √2）
 * @param pts 输入点集
 * @return pair
 *         first: 归一化后的点集
 *         second: 对应的 3x3 归一化变换矩阵 T
 */
std::pair<std::vector<Eigen::Vector2d>, Eigen::Matrix3d>
normalizePoints(const std::vector<Eigen::Vector2d>& pts);

/**
 * @brief 八点法估计基础矩阵 F（线性解，不带RANSAC）
 * @param matches 匹配点对
 * @return 3x3 基础矩阵 F
 */
Eigen::Matrix3d estimateFundamental(const std::vector<Match2D2D>& matches);

/**
 * @brief 八点法 + RANSAC 版本，自动剔除外点
 * @param matches 匹配点对
 * @param iterations RANSAC迭代次数
 * @param threshold 内点阈值
 * @param inliers 输出：内点索引
 * @return 3x3 基础矩阵 F
 */
Eigen::Matrix3d estimateFundamentalRANSAC(
    const std::vector<Match2D2D>& matches,
    int iterations,
    double threshold,
    std::vector<int>& inliers);

} // namespace mvgeom
