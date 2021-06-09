using Dapper;
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using System.Linq;

namespace WaffleDB
{
    public class WaffleDBAPI
    {
        private static string _ip { get => "127.0.0.1"; }
        private static string _dataBaseName { get => "waffleDB"; }
        private static string _connectionString { get => "Server=" + _ip + ";Database=" + _dataBaseName + ";Uid=root;Pwd=;"; }


        public static List<Product> Products { get => TableFetchAll<Product>(); }
        public static List<Addition> Additions { get => TableFetchAll<Addition>(); }
        public static List<Waffle> Waffles { get => TableFetchAll<Waffle>(); }
        public static List<WaffleIngredient> WaffleIngredients { get => TableFetchAll<WaffleIngredient>(); }
        public static List<Ingredient> Ingredients { get => TableFetchAll<Ingredient>(); }
        public static List<NutritionalInformation> NutritionInformations { get => TableFetchAll<NutritionalInformation>(); }
        public static List<Inventory> Inventorys { get => TableFetchAll<Inventory>(); }
        public static List<WaffleStore> WaffleStores { get => TableFetchAll<WaffleStore>(); }
        public static List<PersonalNotification> PersonalNotifications { get => TableFetchAll<PersonalNotification>(); }
        public static List<WaffleOrder> WaffleOrders { get => TableFetchAll<WaffleOrder>(); }
        public static List<ProductOrder> ProductOrders { get => TableFetchAll<ProductOrder>(); }


        private static List<T> TableFetchAll<T>()
        {
            string tableName = typeof(T).ToString(); 
            string sqlCommand = "SELECT * FROM " + tableName;
            List<T> objectList = null;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                objectList = mysqlConnection.Query<T>(sqlCommand).ToList();                
            }

            return objectList;
        }

        public static void InsertEntry(IDataBaseTable dataBaseTable)
        {
            string sqlCommand = dataBaseTable.InsertCommand;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }

        public static void UpdateEntry(IDataBaseTable dataBaseTable)
        {
            string sqlCommand = dataBaseTable.UpdateCommand;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }
    }
}
