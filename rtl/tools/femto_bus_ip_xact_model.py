from sys import argv

temp_bus = r"""    <spirit:busInterface>
      <spirit:name>{interf}</spirit:name>
      <spirit:busType spirit:vendor="ricynlee" spirit:library="user" spirit:name="femto_bus" spirit:version="1.0"/>
      <spirit:abstractionType spirit:vendor="ricynlee" spirit:library="user" spirit:name="femto_bus_rtl" spirit:version="1.0"/>
      <spirit:{status}/>
      <spirit:portMaps>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>REQ</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}req</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>ADDR</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}addr</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>W_RB</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}w_rb</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>ACC</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}acc</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>WDATA</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}wdata</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>RESP</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}resp</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>RDATA</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}rdata</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
      </spirit:portMaps>
    </spirit:busInterface>"""

temp_bus = r"""    <spirit:busInterface>
      <spirit:name>{interf}</spirit:name>
      <spirit:busType spirit:vendor="ricynlee" spirit:library="user" spirit:name="femto_bus" spirit:version="1.0"/>
      <spirit:abstractionType spirit:vendor="ricynlee" spirit:library="user" spirit:name="femto_bus_rtl" spirit:version="1.0"/>
      <spirit:{status}/>
      <spirit:portMaps>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>REQ</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}req</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>ADDR</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}addr</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>W_RB</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}w_rb</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>ACC</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}acc</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>WDATA</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}wdata</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>RESP</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}resp</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
        <spirit:portMap>
          <spirit:logicalPort>
            <spirit:name>RDATA</spirit:name>
          </spirit:logicalPort>
          <spirit:physicalPort>
            <spirit:name>{prefix}rdata</spirit:name>
          </spirit:physicalPort>
        </spirit:portMap>
      </spirit:portMaps>
    </spirit:busInterface>"""



    .format(interf=interf, status=status, prefix=prefix))
