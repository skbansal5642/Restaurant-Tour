const String kSearchRestaurantQuery = """
    query MyQuery(\$nOffset: Int!) {
      search(location: "NYC", limit: 10, offset: \$nOffset) {
        total
        business {
          id
          categories {
            title
          }
          display_phone
          review_count
          reviews(limit: 10) {
            id
            rating
            text
            time_created
            user {
              id
              image_url
              name
              profile_url
            }
          }
          url
          rating
          price
          photos
          phone
          name
          is_closed
          location {
            address1
            address2
            address3
            city
            state
            postal_code
            country
          }
        }
      }
    }
    """;

const String kReviewListQuery = """
    query MyQuery(\$nBusinessId: String!) {
      reviews(business: \$nBusinessId, limit: 10, offset: 10) {
        review {
          id
          rating
          text
          time_created
          user {
            id
            image_url
            name
            profile_url
          }
        }
      }
    }
    """;
