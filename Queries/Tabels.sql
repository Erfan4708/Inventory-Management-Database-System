CREATE TABLE ThirdParty (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL
);

CREATE TABLE Users (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    age INT,
    user_type VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    third_party_id INT,
    FOREIGN KEY (third_party_id) REFERENCES ThirdParty(id)
);

CREATE TABLE Warehouse (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL,
    is_open BIT NOT NULL, 
    created_at DATETIME NOT NULL,
    country VARCHAR(255) NOT NULL,
    third_party_id INT,
    FOREIGN KEY (third_party_id) REFERENCES ThirdParty(id)
);

CREATE TABLE Location (
    id INT PRIMARY KEY IDENTITY(1,1),
    has_container BIT NOT NULL,
    notes TEXT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    created_by_user_id INT,
    warehouse_id INT,
    third_party_id INT,
    FOREIGN KEY (created_by_user_id) REFERENCES Users(id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id),
    FOREIGN KEY (third_party_id) REFERENCES ThirdParty(id)
);

CREATE TABLE Catalog (
    id INT IDENTITY(1,1),
    product_type VARCHAR(255) NOT NULL,
    product_image TEXT,
    manufacturing_cost DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    manufacturing_country VARCHAR(255) NOT NULL,
    weight DECIMAL(10, 2),
    length DECIMAL(10, 2),
    description TEXT,
    sku VARCHAR(255) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    third_party_id INT,
    created_by_user_id INT,
    ordered_by_user_id INT,
    PRIMARY KEY (id, ordered_by_user_id),
    FOREIGN KEY (third_party_id) REFERENCES ThirdParty(id),
    FOREIGN KEY (created_by_user_id) REFERENCES Users(id),
    FOREIGN KEY (ordered_by_user_id) REFERENCES Users(id)
);

CREATE TABLE Orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_time DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    status VARCHAR(255) NOT NULL,
    order_type VARCHAR(255) NOT NULL,
    user_notes TEXT,
    is_gift BIT,
    user_id INT,
    third_party_id INT,
    warehouse_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (third_party_id) REFERENCES ThirdParty(id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouse(id)
);



CREATE TABLE OrderDetails (
    order_id INT,
    product_id INT,
    quantity INT,
    ordered_by_user_id INT,
    PRIMARY KEY (order_id, product_id, ordered_by_user_id),  
    FOREIGN KEY (order_id) REFERENCES Orders(id),
    FOREIGN KEY (product_id, ordered_by_user_id) REFERENCES     Catalog(id, ordered_by_user_id)
);
