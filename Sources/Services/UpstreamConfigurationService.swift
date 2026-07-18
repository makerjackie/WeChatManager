import Foundation

actor UpstreamConfigurationService {
    private let configurationURL: URL
    private let session: URLSession

    init(
        configurationURL: URL = AppConstants.upstreamConfigurationURL,
        session: URLSession = .shared
    ) {
        self.configurationURL = configurationURL
        self.session = session
    }

    func configurations() async throws -> [PatchConfiguration] {
        let (data, response) = try await session.data(from: configurationURL)
        guard let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode else {
            throw AppError(message: "无法获取上游兼容配置，请稍后重试。")
        }
        guard data.count < 2_000_000 else {
            throw AppError(message: "上游兼容配置体积异常，已拒绝处理。")
        }
        return try JSONDecoder().decode([PatchConfiguration].self, from: data)
    }
}
