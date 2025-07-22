require "faker"
require "httparty"
require "csv"

# Clear existing data from the database (in order to avoid FK conflicts)
OrderItem.delete_all
Order.delete_all
Review.delete_all
Product.delete_all
Category.delete_all
User.delete_all

# Import categories from CSV file
CSV.foreach(Rails.root.join("db", "categories.csv"), headers: true) do |row|
  Category.create!(name: row["name"])
end

# 2. Import products from the FakeStore API
response = HTTParty.get("https://fakestoreapi.com/products")
products_data = JSON.parse(response.body)

products_data.each do |product_data|
  # Find category by name or fallback to the first category
  category = Category.find_by(name: product_data["category"]) || Category.first

  Product.create!(
    title: product_data["title"],
    price: product_data["price"],
    description: product_data["description"],
    category: category,
    image_url: product_data["image"],
  )
end

# 3. Generate users, orders, order items, and reviews using Faker
50.times do
  user = User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
  )

  # Create an order for the user
  order = Order.create!(
    user: user,
    status: ["pending", "completed", "shipped"].sample,
    total: Faker::Commerce.price(range: 10..1000.0),
  )

  # Add multiple order items to the order
  rand(1..5).times do
    OrderItem.create!(
      order: order,
      product: Product.all.sample,
      quantity: rand(1..5),
    )
  end

  # Add several reviews for random products by the user
  rand(0..3).times do
    Review.create!(
      product: Product.all.sample,
      user: user,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph,
    )
  end
end

puts "Seeded #{User.count} users, #{Product.count} products, #{Order.count} orders"
