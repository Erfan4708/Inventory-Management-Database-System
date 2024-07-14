#r "nuget: System.Data.SqlClient"

using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;

string connectionString = "Server=.\\Moein;Database=DatabaseTest;User Id=sa;Password=arta0@;";

void InsertThirdPartyData(SqlConnection connection, List<int> thirdPartyIds)
{
    string query = "INSERT INTO ThirdParty (name) OUTPUT INSERTED.id VALUES (@name)";
    using (SqlCommand command = new SqlCommand(query, connection))
    {
        for (int i = 1; i <= 100; i++)
        {
            command.Parameters.Clear();
            command.Parameters.AddWithValue("@name", "Third Party " + i);
            int insertedId = (int)command.ExecuteScalar();
            thirdPartyIds.Add(insertedId);
        }
    }
}

// Method to insert Users data and collect ids
void InsertUsersData(SqlConnection connection, List<int> userIds, List<int> thirdPartyIds)
{
    string query = @"INSERT INTO Users (name, email, password, age, user_type, phone_number, third_party_id) 
                     OUTPUT INSERTED.id VALUES (@name, @mail, @password, @age, @user_type, @phone_number, @third_party_id)";
    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();
        for (int i = 1; i <= 10000; i++)
        {
            int randomThirdPartyId = thirdPartyIds[random.Next(thirdPartyIds.Count)];

            command.Parameters.Clear();
            command.Parameters.AddWithValue("@name", "User " + i);
            command.Parameters.AddWithValue("@mail", "user" + i + "@example.com");
            command.Parameters.AddWithValue("@password", "password" + i);
            command.Parameters.AddWithValue("@age", 20 + (i % 30));
            command.Parameters.AddWithValue("@user_type", "Type" + (i % 5));
            command.Parameters.AddWithValue("@phone_number", "123-456-7890");
            command.Parameters.AddWithValue("@third_party_id", randomThirdPartyId);
            int insertedId = (int)command.ExecuteScalar();
            userIds.Add(insertedId);
        }
    }
}

// Method to insert Warehouse data and collect ids
void InsertWarehouseData(SqlConnection connection, List<int> warehouseIds, List<int> thirdPartyIds)
{
    string query = @"INSERT INTO Warehouse (name, is_open, created_at, country, third_party_id) 
                     OUTPUT INSERTED.id VALUES (@name, @is_open, @created_at, @country, @third_party_id)";
    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();
        for (int i = 1; i <= 1000; i++)
        {
            int randomThirdPartyId = thirdPartyIds[random.Next(thirdPartyIds.Count)];

            command.Parameters.Clear();
            command.Parameters.AddWithValue("@name", "Warehouse " + i);
            command.Parameters.AddWithValue("@is_open", true);
            command.Parameters.AddWithValue("@created_at", DateTime.Now);
            command.Parameters.AddWithValue("@country", "Country " + (i % 50));
            command.Parameters.AddWithValue("@third_party_id", randomThirdPartyId);
            int insertedId = (int)command.ExecuteScalar();
            warehouseIds.Add(insertedId);
        }
    }
}

// Method to insert Location data
void InsertLocationData(SqlConnection connection, List<int> userIds, List<int> warehouseIds, List<int> thirdPartyIds)
{
    string query = @"INSERT INTO Location (has_container, notes, latitude, longitude, created_by_user_id, warehouse_id, third_party_id) 
                     VALUES (@has_container, @notes, @latitude, @longitude, @created_by_user_id, @warehouse_id, @third_party_id)";
    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();
        for (int i = 1; i <= 10000; i++)
        {
            int randomThirdPartyId = thirdPartyIds[random.Next(thirdPartyIds.Count)];
            int randomUserId = userIds[random.Next(userIds.Count)];
            int randomWarehouseId = warehouseIds[random.Next(warehouseIds.Count)];

            command.Parameters.Clear();
            command.Parameters.AddWithValue("@has_container", true);
            command.Parameters.AddWithValue("@notes", "Notes " + i);
            command.Parameters.AddWithValue("@latitude", 50.0 + (i % 50));
            command.Parameters.AddWithValue("@longitude", 10.0 + (i % 50));
            command.Parameters.AddWithValue("@created_by_user_id", randomUserId);
            command.Parameters.AddWithValue("@warehouse_id", randomWarehouseId);
            command.Parameters.AddWithValue("@third_party_id", randomThirdPartyId);
            command.ExecuteNonQuery();
        }
    }
}

// Method to insert Catalog data and return product id, created_by_user_id pairs
List<(int productId, int createdByUserId)> InsertCatalogData(SqlConnection connection, List<int> userIds, List<int> thirdPartyIds)
{
    string query = @"INSERT INTO Catalog (product_type, product_image, manufacturing_cost, selling_price, manufacturing_country, weight, length, description, sku, product_name, third_party_id, created_by_user_id, ordered_by_user_id) 
                     OUTPUT INSERTED.id, INSERTED.created_by_user_id VALUES (@product_type, @product_image, @manufacturing_cost, @selling_price, @manufacturing_country, @weight, @length, @description, @sku, @product_name, @third_party_id, @created_by_user_id, @ordered_by_user_id)";
    List<(int productId, int createdByUserId)> productInfoList = new List<(int, int)>();

    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();
        for (int i = 1; i <= 10000; i++)
        {
            int randomThirdPartyId = thirdPartyIds[random.Next(thirdPartyIds.Count)];
            int randomCreatedById = userIds[random.Next(userIds.Count)];
            int randomOrderedById = userIds[random.Next(userIds.Count)];

            command.Parameters.Clear();
            command.Parameters.AddWithValue("@product_type", "Type " + i);
            command.Parameters.AddWithValue("@product_image", "http://example.com/image" + i);
            command.Parameters.AddWithValue("@manufacturing_cost", 10.0 + (i % 100));
            command.Parameters.AddWithValue("@selling_price", 15.0 + (i % 100));
            command.Parameters.AddWithValue("@manufacturing_country", "Country " + (i % 50));
            command.Parameters.AddWithValue("@weight", 1.0 + (i % 10));
            command.Parameters.AddWithValue("@length", 2.0 + (i % 20));
            command.Parameters.AddWithValue("@description", "Description " + i);
            command.Parameters.AddWithValue("@sku", "SKU" + i);
            command.Parameters.AddWithValue("@product_name", "Product " + i);
            command.Parameters.AddWithValue("@third_party_id", randomThirdPartyId);
            command.Parameters.AddWithValue("@created_by_user_id", randomCreatedById);
            command.Parameters.AddWithValue("@ordered_by_user_id", randomOrderedById);

            using (SqlDataReader reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    int productId = reader.GetInt32(0);
                    productInfoList.Add((productId, randomOrderedById));
                }
            }
        }
    }
    return productInfoList;
}

// Method to insert Orders data and collect ids
void InsertOrdersData(SqlConnection connection, List<int> orderIds, List<int> userIds, List<int> warehouseIds, List<int> thirdPartyIds)
{
    string query = @"INSERT INTO Orders (order_time, total_cost, status, order_type, user_notes, is_gift, user_id, third_party_id, warehouse_id) 
                     OUTPUT INSERTED.id VALUES (@order_time, @total_cost, @status, @order_type, @user_notes, @is_gift, @user_id, @third_party_id, @warehouse_id)";

    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();

        for (int i = 1; i <= 10000; i++)
        {
            int randomThirdPartyId = thirdPartyIds[random.Next(thirdPartyIds.Count)];
            int randomUserId = userIds[random.Next(userIds.Count)];
            int randomWarehouseId = warehouseIds[random.Next(warehouseIds.Count)];

            // Generate a random date within a range (adjust the range as needed)
            DateTime startDate = new DateTime(2020, 1, 1);  // Start date for random date range
            DateTime endDate = DateTime.Now;  // End date for random date range
            TimeSpan dateRange = endDate - startDate;
            DateTime randomDate = startDate.AddDays(random.Next(dateRange.Days));

            command.Parameters.Clear();
            command.Parameters.AddWithValue("@order_time", randomDate);
            command.Parameters.AddWithValue("@total_cost", 100.0 + (i % 1000));
            command.Parameters.AddWithValue("@status", "Status " + (i % 5));
            command.Parameters.AddWithValue("@order_type", "Type " + (i % 3));
            command.Parameters.AddWithValue("@user_notes", "User notes " + i);
            command.Parameters.AddWithValue("@is_gift", (i % 2 == 0) ? 1 : 0);
            command.Parameters.AddWithValue("@user_id", randomUserId);
            command.Parameters.AddWithValue("@third_party_id", randomThirdPartyId);
            command.Parameters.AddWithValue("@warehouse_id", randomWarehouseId);

            int insertedId = (int)command.ExecuteScalar();
            orderIds.Add(insertedId);
        }
    }
}

// Method to insert OrderDetails data
void InsertOrderDetailsData(SqlConnection connection, List<int> orderIds, List<int> productIds, List<int> userIds, List<(int, int)> productInfoList)
{
    string query = @"INSERT INTO OrderDetails (order_id, product_id, quantity, ordered_by_user_id) 
                     VALUES (@order_id, @product_id, @quantity, @ordered_by_user_id)";

    using (SqlCommand command = new SqlCommand(query, connection))
    {
        Random random = new Random();
        foreach (int orderId in orderIds)
        {
            int randomQuantity = random.Next(1, 10);  // Example: Random quantity between 1 and 10
            var orderuser = productInfoList[random.Next(productInfoList.Count)];
            command.Parameters.Clear();
            command.Parameters.AddWithValue("@order_id", orderId);
            command.Parameters.AddWithValue("@product_id", orderuser.Item1);
            command.Parameters.AddWithValue("@quantity", randomQuantity);
            command.Parameters.AddWithValue("@ordered_by_user_id", orderuser.Item2);

            command.ExecuteNonQuery();
        }
    }
}
// Main method to orchestrate the data insertion process
void Main()
{
    using (SqlConnection mainConnection = new SqlConnection(connectionString))
    {
        mainConnection.Open();

        List<int> thirdPartyIds = new List<int>();
        List<int> userIds = new List<int>();
        List<int> warehouseIds = new List<int>();
        List<int> orderIds = new List<int>();
        List<(int productId, int createdByUserId)> productInfoList = new List<(int, int)>();
        Dictionary<int, int> orderUserMap = new Dictionary<int, int>();

        try
        {
            // Insert data and store generated ids
            InsertThirdPartyData(mainConnection, thirdPartyIds);
            Console.WriteLine("Inserted ThirdParty data successfully.");

            InsertUsersData(mainConnection, userIds, thirdPartyIds);
            Console.WriteLine("Inserted Users data successfully.");

            InsertWarehouseData(mainConnection, warehouseIds, thirdPartyIds);
            Console.WriteLine("Inserted Warehouse data successfully.");

            InsertLocationData(mainConnection, userIds, warehouseIds, thirdPartyIds);
            Console.WriteLine("Inserted Location data successfully.");

            // Insert Catalog data and store (productId, createdByUserId) pairs
            productInfoList = InsertCatalogData(mainConnection, userIds, thirdPartyIds);
            Console.WriteLine("Inserted Catalog data successfully.");

            InsertOrdersData(mainConnection, orderIds, userIds, warehouseIds, thirdPartyIds);
            Console.WriteLine("Inserted Orders data successfully.");

            // Extract productId from productInfoList for use in InsertOrderDetailsData
            List<int> productIds = productInfoList.Select(pi => pi.productId).ToList();

            InsertOrderDetailsData(mainConnection, orderIds, productIds, userIds, productInfoList);
            Console.WriteLine("Inserted OrderDetails data successfully.");

            Console.WriteLine("Data insertion completed successfully.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }
        finally
        {
            mainConnection.Close();
        }
    }
}
