using Dapper;
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using System.Linq;

namespace WaffleDB
{
    public class WaffleDBAPI
    {
        private static string _connectionString { get => "Server=127.0.0.1;Database=waffledb;Uid=root;Pwd=;"; }

        public static List<Waffle> GetAllWaffles()
        {
            string sql = "SELECT * FROM Waffle";

            using (MySqlConnection con = new MySqlConnection(_connectionString))
            {
                List<Waffle> orderDetails = con.Query<Waffle>(sql).ToList();

                // null?

                return orderDetails;
            }               
        }
    }
}
