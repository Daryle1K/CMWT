<!-- #include file=_core.asp -->
<!-- #include file=_chart2.asp -->
<%
'-----------------------------------------------------------------------------
' filename....... office.asp
' lastupdate..... 12/09/2016
' description.... microsoft office versions and install counts for each
'-----------------------------------------------------------------------------
Response.Expires = -1
time1 = Timer

PageTitle = "Office Version Installs"
PageBackLink = "software.asp"
PageBackName = "Software"

SortBy  = CMWT_GET("s", "OfficeProduct")
QueryON = CMWT_GET("qq", "")
tcount  = CMWT_CM_CLIENTCOUNT()

CMWT_NewPage "", "", ""

%>
<!-- #include file="_sm.asp" -->
<!-- #include file="_banner.asp" -->
<%
	
query1 = "SELECT COUNT(*) AS Computers FROM (SELECT DISTINCT ResourceID FROM dbo.v_R_System) AS T1"

Set conn = Server.CreateObject("ADODB.Connection")
conn.ConnectionTimeOut = 5
conn.Open Application("DSN_CMDB")
Set cmd = Server.CreateObject("ADODB.Command")
Set rs  = Server.CreateObject("ADODB.Recordset")

rs.CursorLocation = adUseClient
rs.CursorType = adOpenStatic
rs.LockType = adLockReadOnly
Set cmd.ActiveConnection = conn
cmd.CommandType = adCmdText
cmd.CommandText = query1
rs.Open cmd
If Not(rs.BOF And rs.EOF) Then
	tcount = rs.Fields("Computers").value
Else
	tcount = 0
End If
rs.Close
Set rs = Nothing
Set cmd = Nothing

query = "SELECT DISTINCT " & _
	"DBO.V_GS_INSTALLED_SOFTWARE_CATEGORIZED.ARPDisplayName0 AS OfficeProduct, " & _
	"COUNT(ResourceID) AS QTY " & _
	"FROM " & _
	"DBO.V_GS_INSTALLED_SOFTWARE_CATEGORIZED " & _
	"WHERE " & _
	"DBO.V_GS_INSTALLED_SOFTWARE_CATEGORIZED.ARPDisplayName0 LIKE '%Microsoft Office%' " & _
	"GROUP BY " & _
	"DBO.V_GS_INSTALLED_SOFTWARE_CATEGORIZED.ARPDisplayName0 " & _
	"ORDER BY " & SortBy

Set cmd = Server.CreateObject("ADODB.Command")
Set rs  = Server.CreateObject("ADODB.Recordset")
rs.CursorLocation = adUseClient
rs.CursorType = adOpenStatic
rs.LockType = adLockReadOnly
Set cmd.ActiveConnection = conn
cmd.CommandType = adCmdText
cmd.CommandText = query
rs.Open cmd

Response.Write "<table class=""tfx"">"

If Not(rs.BOF And rs.EOF) Then
	found = True
	Do Until rs.EOF
		f1 = rs.Fields("OfficeProduct").value
		f2 = rs.Fields("QTY").value
		Response.Write "<tr class=""tr1"">" & _
			"<td class=""td6 v10 w300"">" & _
			"<a href=""app.asp?pn=" & f1 & """ title=""Show Computers with " & f1 & """>" & f1 & "</a></td>" & _
				"<td class=""td6 v10"">"
		CMWT_TABLE_GRAPH2 f2, tcount
		Response.Write "</td></tr>"
		rs.MoveNext
	Loop
Else
	Response.Write "<tr class=""h100 tr1""><td class=""td6 v10 ctr"">" & _
		"No inventory found for Office installations</td></tr>"
End If

Response.Write "</table>"

rs.Close
conn.Close
Set rs = Nothing
Set cmd = Nothing
Set conn = Nothing

CMWT_SHOW_QUERY() 
CMWT_Footer()
Response.Write "</body></html>"
%>
