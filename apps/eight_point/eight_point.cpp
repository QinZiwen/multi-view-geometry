#include "eight_point.h"
#include <iostream>

int main() {
    // 构造测试匹配点
    std::vector<mvgeom::Match2D2D> matches = {
        {{10, 20}, {12, 21}},
        {{30, 50}, {31, 49}},
        {{15, 40}, {14, 42}},
        {{50, 80}, {52, 78}},
        {{25, 35}, {26, 36}},
        {{60, 90}, {61, 91}},
        {{70, 20}, {72, 19}},
        {{80, 40}, {82, 41}},
        {{90, 60}, {88, 59}},
        {{100, 80}, {102, 81}}
    };

    std::vector<int> inliers;
    Eigen::Matrix3d F = mvgeom::estimateFundamentalRANSAC(matches, 1000, 0.01, inliers);

    std::cout << "Estimated Fundamental Matrix (RANSAC):\n" << F << "\n";
    std::cout << "Number of inliers: " << inliers.size() << std::endl;

    std::cout << "Inlier indices: ";
    for (int idx : inliers) std::cout << idx << " ";
    std::cout << std::endl;

    return 0;
}
