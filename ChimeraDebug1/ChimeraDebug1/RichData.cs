using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Gentex.MES.LegacyDataClient;
namespace ChimeraDebug1
{
    class RichData
    {
        public void SubmitToRichData(string serial, string mac_address, DateTime time, string location, string employee, string dallas, string singlewire1, string singlewire2, string uart, string hs_can,
           string multi_can, string aux_io, string signal_conversion, string voltage_io, string i2c, string notes, string sb, Gentex.MES.LegacyDataClient.DataResultEnum passFailValue)
        {
            string _machineName = Environment.MachineName;
            try
            {
                var client = new Gentex.MES.LegacyDataClient.RequestReplyClient("LegacyDataClientServiceRR");
                var response = client.LogDataRequestWithResponse(Gentex.MES.LegacyDataClient.RequestFactory.LogMeasurements("ChimeraDebugger")


                        .Description("Chimera Debugger Data")
                        .Location(location) // this location and value combo is necessary in order for manufacturing apps to work
                        .IdentifierCode(serial)
                        .EmployeeName(employee)
                        .StartTime(time)
                        .EndTime(DateTime.Now)
                        .OverallResult(passFailValue)
                        .Publish(false)

                        .Measurements()
                            .BeginWith().Name(("Mac Address"))

                                .Value(mac_address)

                                .EndWith()
                            .BeginWith().Name(("Dallas"))

                                .Value(dallas.PadLeft(28))

                                .EndWith()
                            .BeginWith().Name(("SingleWire1"))

                                .Value(singlewire1.PadLeft(20))

                                .EndWith()
                             .BeginWith().Name(("SingleWire2"))

                                .Value(singlewire2.PadLeft(20))

                                .EndWith()
                             .BeginWith().Name(("UART"))

                                .Value(uart.PadLeft(28))

                                .EndWith()
                             .BeginWith().Name(("Dedicated HighSpeed CAN"))

                                .Value(hs_can)

                                .EndWith()
                             .BeginWith().Name(("Multi CAN"))

                                .Value(multi_can.PadLeft(20))

                                .EndWith()
                             .BeginWith().Name(("Aux IO"))

                                .Value(aux_io.PadLeft(28))

                                .EndWith()
                             .BeginWith().Name(("Signal Conversion"))

                                .Value(signal_conversion.PadLeft(12))

                                .EndWith()
                             .BeginWith().Name(("Voltage IO"))

                                .Value(voltage_io.PadLeft(20))

                                .EndWith()
                             .BeginWith().Name(("I2C"))

                                .Value(i2c.PadLeft(28))

                                .EndWith()
                             .BeginWith().Name(("Notes"))

                                .Value(notes+ "\r\n")             
                                .EndWith()
                                
                                .BeginWith().Name("<<<<<<Log File>>>>>>")
                                
                                .Value("\r\n"+sb)
                                .EndWith()
                        .Build());

                if (response.ID.HasValue)
                    MessageBox.Show("Added to database!", "CREATED!", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                else
                    throw new Exception("Did not get valid response from RichData service.  Possible data corruption!");

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.ToString());
            }
        }
    }
}
