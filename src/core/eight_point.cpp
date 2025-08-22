#include "eight_point.h"
#include <Eigen/SVD>
#include <iostream>
#include <random>
#include <set>

namespace mvgeom {

// ---------------------------
// 归一化点
// ---------------------------
std::pair<std::vector<Eigen::Vector2d>, Eigen::Matrix3d>
normalizePoints(const std::vector<Eigen::Vector2d>& pts) {
    std::vector<Eigen::Vector2d> normalized_pts;
    Eigen::Matrix3d T = Eigen::Matrix3d::Identity();

    if (pts.empty()) return {normalized_pts, T};

    // 1. 计算质心
    Eigen::Vector2d centroid(0.0, 0.0);
    for (const auto& p : pts) centroid += p;
    centroid /= static_cast<double>(pts.size());

    // 2. 平移质心到原点
    std::vector<Eigen::Vector2d> centered_pts;
    centered_pts.reserve(pts.size());
    for (const auto& p : pts) centered_pts.push_back(p - centroid);

    // 3. 平均距离
    double mean_dist = 0.0;
    for (const auto& p : centered_pts) mean_dist += p.norm();
    mean_dist /= static_cast<double>(centered_pts.size());

    // 4. 缩放
    double scale = std::sqrt(2.0) / mean_dist;

    // 5. 构造归一化矩阵
    T << scale, 0.0, -scale * centroid.x(),
         0.0, scale, -scale * centroid.y(),
         0.0, 0.0, 1.0;

    // 6. 对每个点做齐次变换
    normalized_pts.reserve(pts.size());
    for (const auto& p : pts) {
        Eigen::Vector3d ph(p.x(), p.y(), 1.0);
        Eigen::Vector3d pn = T * ph;
        normalized_pts.emplace_back(pn.x() / pn.z(), pn.y() / pn.z());
    }

    return {normalized_pts, T};
}

// ---------------------------
// 八点法线性解
// ---------------------------
Eigen::Matrix3d estimateFundamental(const std::vector<Match2D2D>& matches) {
    Eigen::Matrix3d F = Eigen::Matrix3d::Zero();

    if (matches.size() < 8) {
        std::cerr << "[estimateFundamental] Need at least 8 points!" << std::endl;
        return F;
    }

    // 提取两组点
    std::vector<Eigen::Vector2d> pts1, pts2;
    pts1.reserve(matches.size());
    pts2.reserve(matches.size());
    for (const auto& m : matches) {
        pts1.push_back(m.p1);
        pts2.push_back(m.p2);
    }

    // 归一化
    Eigen::Matrix3d T1, T2;
    std::tie(pts1, T1) = normalizePoints(pts1);
    std::tie(pts2, T2) = normalizePoints(pts2);

    // 构造线性系统
    Eigen::MatrixXd A(matches.size(), 9);
    for (size_t i = 0; i < matches.size(); ++i) {
        double x1 = pts1[i].x(), y1 = pts1[i].y();
        double x2 = pts2[i].x(), y2 = pts2[i].y();
        A(i, 0) = x2 * x1; A(i, 1) = x2 * y1; A(i, 2) = x2;
        A(i, 3) = y2 * x1; A(i, 4) = y2 * y1; A(i, 5) = y2;
        A(i, 6) = x1;      A(i, 7) = y1;      A(i, 8) = 1.0;
    }

    // SVD 解
    Eigen::JacobiSVD<Eigen::MatrixXd> svd(A, Eigen::ComputeFullV);
    Eigen::VectorXd f = svd.matrixV().col(8);
    Eigen::Matrix3d F_normalized;
    F_normalized << f(0), f(1), f(2),
                    f(3), f(4), f(5),
                    f(6), f(7), f(8);

    // rank-2 强制
    Eigen::JacobiSVD<Eigen::Matrix3d> svdF(F_normalized, Eigen::ComputeFullU | Eigen::ComputeFullV);
    Eigen::Vector3d singular = svdF.singularValues();
    singular(2) = 0.0;
    F_normalized = svdF.matrixU() * singular.asDiagonal() * svdF.matrixV().transpose();

    // 反归一化
    F = T2.transpose() * F_normalized * T1;

    return F;
}

// ---------------------------
// 八点法 + RANSAC
// ---------------------------
Eigen::Matrix3d estimateFundamentalRANSAC(
    const std::vector<Match2D2D>& matches,
    int iterations,
    double threshold,
    std::vector<int>& inliers_out) {

    Eigen::Matrix3d best_F = Eigen::Matrix3d::Zero();
    size_t N = matches.size();
    size_t best_inliers_count = 0;
    inliers_out.clear();

    if (N < 8) {
        std::cerr << "[estimateFundamentalRANSAC] Need at least 8 points!" << std::endl;
        return best_F;
    }

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, N - 1);

    for (int iter = 0; iter < iterations; ++iter) {
        // 随机抽 8 个点
        std::vector<Match2D2D> sample_matches;
        std::set<int> idx_set;
        while (idx_set.size() < 8) idx_set.insert(dis(gen));
        for (int idx : idx_set) sample_matches.push_back(matches[idx]);

        // 估计 F
        Eigen::Matrix3d F_candidate = estimateFundamental(sample_matches);

        // 计算内点
        std::vector<int> inliers_candidate;
        for (size_t i = 0; i < N; ++i) {
            Eigen::Vector3d p1(matches[i].p1.x(), matches[i].p1.y(), 1.0);
            Eigen::Vector3d p2(matches[i].p2.x(), matches[i].p2.y(), 1.0);
            double err = std::abs(p2.transpose() * F_candidate * p1);
            if (err < threshold) inliers_candidate.push_back(i);
        }

        // 更新最佳 F
        if (inliers_candidate.size() > best_inliers_count) {
            best_inliers_count = inliers_candidate.size();
            best_F = F_candidate;
            inliers_out = inliers_candidate;
        }
    }

    return best_F;
}

} // namespace mvgeom
