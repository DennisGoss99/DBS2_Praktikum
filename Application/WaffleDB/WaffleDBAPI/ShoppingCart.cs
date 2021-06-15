using System.Collections.Generic;

namespace WaffleDB
{
    public class ShoppingCart
    {
        private WaffleOrder _waffleOrderInstance = null;
        private List<KeyValuePair<Product, int>> _productOrderList = new List<KeyValuePair<Product, int>>();

        public int AmountOfProducts 
        {
            get
            {
                int sum = 0; 

                foreach(var item in _productOrderList)
                {
                    int amount = item.Value;

                    sum += amount;
                }

                return sum;
            }            
        }

        public ShoppingCart(WaffleOrder waffleOrder)
        {
            _waffleOrderInstance = waffleOrder;
        }

        public void AddProduct(Product product, int amount)
        {
            KeyValuePair<Product, int> data = new KeyValuePair<Product, int>(product, amount);

            _productOrderList.Add(data);
        }

        public void PurchaseProducts()
        {
            string sqlCommand;

            foreach (var item in _productOrderList)
            {
                Product product = item.Key;
                int amount = item.Value;

                ProductOrder productOrder = new ProductOrder(_waffleOrderInstance.idOrder, product.idProduct, amount);

                sqlCommand = productOrder.InsertCommand;

                WaffleDBAPI.SQLExecuteCommand(sqlCommand);
            }
        }

        public void FinishOrder()
        {
            _waffleOrderInstance.paymentStatus = 1;

            string sqlCommand = _waffleOrderInstance.UpdateCommand;

            WaffleDBAPI.SQLExecuteCommand(sqlCommand);
        }
    }
}