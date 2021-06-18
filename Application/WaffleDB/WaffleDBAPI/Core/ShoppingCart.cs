using System.Collections.Generic;

namespace WaffleDB
{
    public class ShoppingCart
    {
        /// <summary>
        /// ProductID, Amount 
        /// </summary>
        public List<KeyValuePair<IProduct, int>> ProductOrderList = new List<KeyValuePair<IProduct, int>>();

        public int SumOfCurrentProductsElemets 
        {
            get
            {
                int sum = 0;          

                foreach (var item in ProductOrderList)
                {
                    int amount = item.Value;

                    sum += amount;
                }

                return sum;
            }            
        }

        public void FinishOrder(int storeID)
        {
            string sqlCommand = null;

            WaffleOrder waffleOrder = WaffleDBAPI.CreateNewWaffleOrder(storeID);

            waffleOrder.totalAmount = SumOfCurrentProductsElemets;

            WaffleDBAPI.SQLExecuteInsertEntry(waffleOrder);

            foreach (var item in ProductOrderList)
            {
                int amount = item.Value;
                IProduct product = item.Key;
                int productID = product.idProduct;            

                ProductOrder productOrder = new ProductOrder(waffleOrder.idOrder, productID, amount);

                sqlCommand = productOrder.InsertCommand;

                WaffleDBAPI.SQLExecuteCommand(sqlCommand);
            }

            //--- Set as "Purchased" ---------------------
            waffleOrder.paymentStatus = 1;
            sqlCommand = waffleOrder.UpdateCommand;

            WaffleDBAPI.SQLExecuteCommand(sqlCommand);
            //--------------------------------------------
        }
    }
}