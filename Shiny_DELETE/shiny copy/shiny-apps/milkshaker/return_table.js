
(function(DataTables){
	var table = $('#createSearchTable').DataTable();
 
	var data = table
    	.rows()
    	.data();
 
	alert( 'The table has '+data.length+' records' );
});