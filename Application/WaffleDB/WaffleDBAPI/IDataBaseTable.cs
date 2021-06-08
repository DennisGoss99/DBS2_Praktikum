namespace WaffleDB
{
    public interface IDataBaseTable
    {
        string TableName { get; }
        string UpdateCommand { get; }
        string InsertCommand { get; }
    }
}
