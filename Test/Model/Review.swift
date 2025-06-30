/// Модель отзыва.
struct Review: Decodable {

    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
	/// Имя пользователя.
	let first_name: String
	/// Фамилия пользователя.
	let last_name: String
	/// Рейтинг товара.
	let rating: Int
	/// Фото аватара.
	let avatar_url: String
	/// Фото отзывов.
	let reviewImages: [String]
}
