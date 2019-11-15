using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Threading;
using System.Windows.Forms;

namespace ChimeraDebug1
{
    class DevComm
    {

        private DevCommServiceReference.DeviceCommServiceClient ChimeraChan1 = null;
        private long _ChimeraChan1_idx = 0;
        private object indexLock = new object();

        private long ChimeraChan1_idx
        {
            get
            {
                lock (indexLock)
                {
                    return _ChimeraChan1_idx;
                }
            }
            set
            {
                lock (indexLock)
                {
                    _ChimeraChan1_idx = value;
                }
            }
        }

        public DevComm()
        {
        }

        public DevComm(string commandSet, string servicePath)
        {
            if (servicePath != "")
            {
                if (!ServiceRunning())
                {
                    LaunchService(servicePath);
                }
                bool test = Connect(commandSet);
                if (!test)
                {
                    throw new Exception("Not able to connect to service.");
                }
            }
            else
            {
            }
        }
        public DevComm(string commandSet)
        {
            bool test = Connect(commandSet);
        }

        public bool Connect(string commandset)
        {
            ChimeraChan1 = new DevCommServiceReference.DeviceCommServiceClient();
            try
            {
                long index = ChimeraChan1_idx;
                bool result = ChimeraChan1.Create(commandset, out index);
                ChimeraChan1_idx = index;
                Debug.Print(Convert.ToString(ChimeraChan1_idx));
                return result;
            }
            catch (Exception error)
            {
                throw new Exception("Error connecting to Devicecomm Service.\r\n" + error.Message);
            }
        }

        public bool Initialize(string HardwareType, StringDictionary settings)
        {
            bool result = false;
            result = ChimeraChan1.Initialize(ChimeraChan1_idx, HardwareType, StringDictionaryToStringArray(ref settings));
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();

                throw new Exception(errorMessage);
            }
            return result;
        }

        public bool Do(string command)
        {
            string[] outParms;
            bool result = false;
            result = Do(command, null, out outParms);
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            return result;
        }
       

        public OrderedDictionary Do(string command, OrderedDictionary inparams)
        {
            string[] inParams = OrderedDictionarytoStringArray(ref inparams);
            string[] outParams;
            bool result;
            if (inparams.Count == 0)
            {
                result = Do(command, null, out outParams);
            }
            else
            {
                result = Do(command, inParams, out outParams);
            }

            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            if (outParams.Length == 0)
            {
                return new OrderedDictionary();
            }
            else
            {
                return StringArrayToOrderedDictionary(outParams);
            }
        }

        public bool Do(string command, string[] inParams, out string[] outParams)
        {
            bool result = false;
            result = ChimeraChan1.DoCommand(ChimeraChan1_idx, command, inParams, out outParams);
            return result;
        }

        public void Do(string command, out OrderedDictionary OD)
        {
            string[] outParams;
            bool result = false;
            result = ChimeraChan1.DoCommand(ChimeraChan1_idx, command, null, out outParams);
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            OD = StringArrayToOrderedDictionary(outParams);
        }
        public OrderedDictionary Do(string command,  OrderedDictionary OD, out OrderedDictionary OS)
        {
            string[] inParams;
            inParams = OrderedDictionarytoStringArray(ref OD);
            string[] outParams;
            bool result = false;
            result = ChimeraChan1.DoCommand(ChimeraChan1_idx, command, inParams, out outParams);
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            OS = StringArrayToOrderedDictionary(outParams);
            return OS;
        }
        public OrderedDictionary Read(string command)
        {
            string[] outParams;
            bool result = false;
            result = ChimeraChan1.ReadCommand(ChimeraChan1_idx, command, out outParams);
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            return StringArrayToOrderedDictionary(outParams);
        }

        public bool Read(string command, out string[] outParams)
        {
            bool result = false;
            result = ChimeraChan1.ReadCommand(ChimeraChan1_idx, command, out outParams);
            return result;
        }

        public bool Write(string command, OrderedDictionary inParams)
        {
            bool result = false;
            result = ChimeraChan1.WriteCommand(ChimeraChan1_idx, command, OrderedDictionarytoStringArray(ref inParams));
            if (!result)
            {
                string errorMessage = ChimeraChan1.GetLastError();
                throw new Exception(errorMessage);
            }
            return result;
        }

        public bool Write(string command, string[] inParams)
        {
            bool result = false;
            result = ChimeraChan1.WriteCommand(ChimeraChan1_idx, command, inParams);
            return result;
        }

        public string GetLastError()
        {
            return ChimeraChan1.GetLastError();
        }

        public bool ShutDown()
        {
            bool result = new bool();

            try
            {
                result = ChimeraChan1.Shutdown(ChimeraChan1_idx);
            }
            catch { }

            try
            {
                ChimeraChan1.Abort();
            }
            catch { }

            return result;
        }

        private string[] StringDictionaryToStringArray(ref StringDictionary SD)
        {
            StringBuilder builder = new StringBuilder();
            foreach (System.Collections.DictionaryEntry entry in SD)
            {
                builder.Append(entry.Key).Append(",").Append(entry.Value).Append(",");
            }
            string[] retVal = builder.ToString().Trim(',').Split(',');
            return retVal;
        }

        private string[] OrderedDictionarytoStringArray(ref OrderedDictionary OD)
        {
            StringBuilder builder = new StringBuilder();
            object[] keys = new object[OD.Keys.Count];
            OD.Keys.CopyTo(keys, 0);
            for (int x = 0; x < keys.Length; x++)
            {
                builder.Append(keys[x]).Append(",");
                bool found = false;
                object valsObj = OD[keys[x]];

                Type TvalsObj = valsObj.GetType();
                if (TvalsObj == typeof(byte[]))
                {
                    byte[] btsVal = (byte[])valsObj;
                    for (int i = 0; i < btsVal.GetUpperBound(0); i++)
                    {
                        builder.Append(Convert.ToString(btsVal[i])).Append(" ");
                    }
                    builder.Append(btsVal[btsVal.GetUpperBound(0)]).Append(",");
                    continue;
                }
                if (TvalsObj == typeof(byte))
                {
                    byte btVal = (byte)valsObj;
                    builder.Append(Convert.ToString(btVal)).Append(",");
                    found = true;
                    continue;
                }
                if (TvalsObj == typeof(UInt16))
                {
                    UInt16 uintVal = (UInt16)valsObj;
                    builder.Append(Convert.ToString(uintVal)).Append(",");
                    found = true;
                    continue;
                }
                if (TvalsObj == typeof(string))
                {
                    string stVal = (string)valsObj;
                    builder.Append(stVal).Append(",");
                    found = true;
                    continue;
                }
                //if (!found)
                //{
                //    throw new Exception("Type not found!");
                //}
            }
            string[] ret = builder.ToString().Trim(',').Split(',');
            return ret;
        }

        public void Reinitialize()
        {
            try
            {
                ChimeraChan1.ReInitialize(ChimeraChan1_idx);
            }
            catch (Exception err)
            {
                throw err;
            }
        }

        public void Dispose()
        {
            try
            {
                if (ChimeraChan1 != null)
                {
                    bool test = ChimeraChan1.Shutdown(ChimeraChan1_idx);
                    test = ChimeraChan1.Destroy(ChimeraChan1_idx);
                    ChimeraChan1.Abort();
                }
            }
            catch (Exception err)
            {
                throw err;
            }
        }

        private string[] DictionaryStringValueToStringArray(ref Dictionary<string, Int32> SV)
        {
            StringBuilder builder = new StringBuilder();
            foreach (KeyValuePair<string, int> entry in SV)
            {
                builder.Append(entry.Key).Append(",").Append(Convert.ToString(entry.Value)).Append(",");
            }
            return builder.ToString().Trim(',').Split(',');
        }

        private StringDictionary StringArrayToStringDictionary(ref string[] SA)
        {
            StringDictionary SD = new StringDictionary();
           // ValidateStringArray(ref SA);
            for (int i = 0; i < SA.Length; i += 2)
            {
                SD.Add(SA[i], SA[i + 1]);
            }
            return SD;
        }

        private OrderedDictionary StringArrayToOrderedDictionary(string[] SA)
        {
            OrderedDictionary OD = new OrderedDictionary();
           // ValidateStringArray(ref SA);
            for (int i = 0; i < SA.Length; i += 2)
            {
                OD.Add(SA[i], StringToValue(SA[i + 1]));
            }
            return OD;
        }

        private object StringToValue(string val)
        {
            byte ReturnByte;
            if (byte.TryParse(val, out ReturnByte))
            {
                return ReturnByte;
            }
            UInt16 ReturnUint16;
            if (UInt16.TryParse(val, out ReturnUint16))
            {
                return ReturnUint16;
            }

            string[] ReturnString = val.ToString().Trim(' ').Split(' ');
            byte[] ReturnBytes = new byte[ReturnString.Length];
            bool converted = true;
            for (int i = 0; i <= ReturnString.GetUpperBound(0); i++)
            {
                if (byte.TryParse(ReturnString[i], out ReturnBytes[i]))
                {
                    ReturnBytes[i] = Convert.ToByte(ReturnString[i]);
                }
                else
                {
                    converted = false;
                }
            }
            if (converted)
            {
                return ReturnBytes;
            }
            else
            {
                converted = true;
                UInt16[] ReturnUints = new UInt16[ReturnBytes.Length];
                for (int i = 0; i <= ReturnString.GetUpperBound(0); i++)
                {
                    if (UInt16.TryParse(ReturnString[i], out ReturnUints[i]))
                    {
                        ReturnBytes[i] = Convert.ToByte(ReturnString[i]);
                    }
                    else
                    {
                        converted = false;
                    }
                }
                if (converted)
                {
                    return ReturnUints;
                }
            }
            if (!converted)
            {
                return val;
                //throw new Exception("String type could not be identified.");
            }
            return null;
        }

        // verify the array is in pairs and no blank elements
       // private void ValidateStringArray(ref string[] SA)
        //{
          //  if (SA.Length % 2 == 0)
            //{
              //  for (int i = 0; i < SA.Length; i++)
                //{
                  //  if (SA[i] == "")
                    //{
                     //   throw (new Exception("String Array has empty element!"));
                    //}
               // }
            //}
            //else
            //{
              //  throw (new Exception("String Array length is not even number of pairs!"));
            //}
        //}

        public bool ServiceRunning()
        {
            Process[] processlist = Process.GetProcesses();
            foreach (Process theprocess in processlist)
            {
                if (theprocess.ProcessName.IndexOf("BundleServer") > -1)
                {
                    return true;
                }
            }
            return false;
        }

        public bool LaunchService(string path)
        {
            bool serverRunning = false;
            serverRunning = ServiceRunning();

            if (!serverRunning)
            {
                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo();
                    psi.WorkingDirectory = path;
                    psi.FileName = "BundleServer.exe";
                    psi.WindowStyle = ProcessWindowStyle.Minimized;
                    Process.Start(psi);
                    Thread.Sleep(500);
                }
                catch
                {
                    MessageBox.Show("Error starting Devicecomm Service");
                    return false;
                }
            }
            return true;
        }

        public bool killService()
        {
            Process[] processlist = Process.GetProcesses();
            bool Done = false;
            foreach (Process theprocess in processlist)
            {
                if (theprocess.ProcessName.IndexOf("BundleServer") > -1)
                {
                    theprocess.Kill();
                    for (int i = 0; i < 100; i++)
                    {
                        if (theprocess.HasExited)
                        {
                            Done = true;
                            break;
                        }
                        Application.DoEvents();
                    }
                    if (Done)
                    {
                        break;
                    }
                }
            }

            if (ChimeraChan1 != null)
            {
                ChimeraChan1.Abort();
            }
            return Done;
        }
    }
}
