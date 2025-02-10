//
//  MCatalogRatingRequest.swift
//  MusadoraKit
//
//  Created by Rudrank Riyam on 18/05/22.
//

import Foundation

/// A request that your app uses to get ratings for items in the Apple Music catalog.
///
/// This structure allows fetching existing ratings for catalog items such as songs,
/// albums, playlists, music videos, and stations.
///
/// Example usage:
/// ```swift
/// // Fetch ratings for multiple songs
/// let request = MCatalogRatingRequest(
///     with: ["1234567890", "0987654321"],
///     item: .song
/// )
///
/// do {
///     let ratings = try await request.response()
///     print("Fetched ratings: \(ratings)")
/// } catch {
///     print("Failed to fetch ratings: \(error)")
/// }
/// ```
public struct MCatalogRatingRequest {

  /// The type of music item to fetch ratings for.
  private var type: CatalogRatingMusicItemType

  /// The unique identifiers of the items to fetch ratings for.
  private var ids: [MusicItemID]

  /// Creates a request to get ratings for the unique identifiers of the given catalog item.
  /// - Parameters:
  ///   - ids: The unique identifiers of the catalog item.
  ///   - type: The type of the catalog item. Possible values: `song`, `album`, `playlist`, `musicVideo`, `station`.
  public init(with ids: [MusicItemID], item type: CatalogRatingMusicItemType) {
    self.type = type
    self.ids = ids
  }

  /// Creates a request to get the rating for the unique identifier of the given catalog item.
  /// - Parameters:
  ///   - id: The unique identifier of the catalog item.
  ///   - type: The type of the catalog item. Possible values: `song`, `album`, `playlist`, `musicVideo`, `station`.
  public init(with id: MusicItemID, item type: CatalogRatingMusicItemType) {
    self.type = type
    self.ids = [id]
  }

  /// Fetches the given rating(s) of the given catalog item
  /// that matches the unique identifier(s) for the request.
  public func response() async throws -> RatingsResponse {
    let url = try catalogRatingsEndpointURL
    let request = MusicDataRequest(urlRequest: URLRequest(url: url))
    let response = try await request.response()
    return try JSONDecoder().decode(RatingsResponse.self, from: response.data)
  }
}

extension MCatalogRatingRequest {
  internal var catalogRatingsEndpointURL: URL {
    get throws {
      var components = AppleMusicURLComponents()
      var queryItems: [URLQueryItem]?
      components.path = "me/ratings/\(type.rawValue)"

      let ids = ids.map { $0.rawValue }.joined(separator: ",")
      queryItems = [URLQueryItem(name: "ids", value: ids)]

      components.queryItems = queryItems

      guard let url = components.url else {
        throw URLError(.badURL)
      }
      return url
    }
  }
}
