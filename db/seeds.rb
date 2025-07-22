require "faker"
require "httparty"
require "csv"

# Clear existing data from the database (order matters to avoid FK conflicts)
ProductTag.delete_all
Tag.delete_all
OrderItem.delete_all
Order.delete_all
Review.delete_all
Product.delete_all
Category.delete_all
User.delete_all

# 1. Import categories from a CSV file
CSV.foreach(Rails.root.join("db", "categories.csv"), headers: true) do |row|
  Category.create!(name: row["name"])
end

# 2. Create Tags (to establish many-to-many relationship with products)
tag_names = ["New Arrival", "On Sale", "Limited Edition", "Best Seller"]
tags = tag_names.map { |name| Tag.create!(name: name) }

# 3. Fetch and create products from the FakeStore API
response = HTTParty.get("https://fakestoreapi.com/products")
products_data = JSON.parse(response.body)

products_data.each do |product_data|
  # Match category by name, or fallback to the first category if not found
  category = Category.find_by(name: product_data["category"]) || Category.first

  product = Product.create!(
    title: product_data["title"],
    price: product_data["price"],
    description: product_data["description"],
    category: category,
    image_url: product_data["image"],
  )

  # Randomly assign 1–3 tags to each product (many-to-many association)
  product.tags << tags.sample(rand(1..3))
end

# 4. Create users, orders, order items, and reviews using Faker
50.times do
  user = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
  )

  # Each user gets one order
  order = Order.create!(
    user: user,
    status: ["pending", "completed", "shipped"].sample,
    total: Faker::Commerce.price(range: 10..1000.0),
  )

  # Each order gets 1–5 random products
  rand(1..5).times do
    OrderItem.create!(
      order: order,
      product: Product.all.sample,
      quantity: rand(1..5),
    )
  end

  # Each user may leave 0–3 reviews on random products
  rand(0..3).times do
    Review.create!(
      product: Product.all.sample,
      user: user,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph,
    )
  end
end

puts "✅ Seeded #{User.count} users, #{Product.count} products, #{Order.count} orders, #{Tag.count} tags"
