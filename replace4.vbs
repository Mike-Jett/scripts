Const ForReading = 1
Const ForWriting = 2

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile("C:\Mike Jett\Scripts\input.txt", ForReading)

strText = objFile.ReadAll
objFile.Close
strNewText = Replace(strText, vbCrLf, "]" & vbCrLf & "= acqsource.[")

Set objFile = objFSO.OpenTextFile("C:\Mike Jett\Scripts\output.txt", ForWriting)
objFile.WriteLine strNewText
objFile.Close