<?xml version="1.0" encoding="UTF-8"?>
<metadata-profile xmlns="http://nuix.com/fbi/metadata-profile">
  <metadata-list>
    <metadata type="CUSTOM" name="ExportID" />
    <metadata type="CUSTOM" name="ExportID-Duplicates" />
    <metadata type="SPECIAL" name="Markup Sets" />
    <metadata type="SPECIAL" name="Name" />
    <metadata type="DERIVED" name="Item Date" customDateFormat="yyyy-MM-dd HH:mm" default-column-width="120">
      <first-non-blank>
        <metadata type="SPECIAL" name="Item Date" />
      </first-non-blank>
    </metadata>
    <metadata type="SPECIAL" name="Comment" />
    <metadata type="DERIVED" name="Source">
      <first-non-blank>
        <metadata type="CUSTOM" name="Source" />
        <metadata type="SPECIAL" name="Case Name" />
      </first-non-blank>
    </metadata>
    <metadata type="DERIVED" name="Document Date" customDateFormat="yyyy-MM-dd">
      <first-non-blank>
        <metadata type="SPECIAL" name="Item Date" />
      </first-non-blank>
    </metadata>
    <metadata type="DERIVED" name="Document Time" customDateFormat="HH:mm">
      <first-non-blank>
        <metadata type="SPECIAL" name="Item Date" />
      </first-non-blank>
    </metadata>
    <metadata type="DERIVED" name="Original File Name">
      <first-non-blank>
        <metadata type="SPECIAL" name="Name" />
      </first-non-blank>
    </metadata>
    <metadata type="DERIVED" name="Original File Kind">
      <first-non-blank>
        <metadata type="SPECIAL" name="Kind" />
      </first-non-blank>
    </metadata>
    <metadata type="SPECIAL" name="Path Name" default-column-width="297" />
    <metadata type="DERIVED" name="Attached or Embedded Items">
      <first-non-blank>
        <metadata type="SPECIAL" name="Material Child Names" />
      </first-non-blank>
    </metadata>
    <metadata type="SPECIAL" name="GUID" />
    <metadata type="PROPERTY" name="Original MD5 Digest" />
  </metadata-list>
</metadata-profile>
