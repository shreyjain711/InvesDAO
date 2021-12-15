import React from 'react';

function GetStatusLine(props) {
    if (props.stageOfDao === "0") {
        return <p>Raised <b>{props.raisedPercent}%</b> of {props.raiseGoal}</p>;
    } else if (props.stageOfDao === "1") {
        return <p>A decentralised org has been formed!</p>;
    } else {
        return <p>The Raise Campaign was called off, funds returned</p>;
    }
}

function CreateRaiseDaoCardLayout (props) {
    const allDaoDetails = props.alldaos;
    return( 
        <div>
        {
            allDaoDetails.map(daoDetails => {return (
                <RaiseDaoCard details={daoDetails} />        
            )})
        }
        </div>
    )
    // elements = elements + <EmptyRaiseDaoCard />;
    // console.log(elements)
    // return elements;
}

function RaiseDaoCard(props) {
    const title = props.details[0];
    const raiseGoal = props.details[1] / 10 ** 18;
    const yetToBeRaised = props.details[2] / 10 ** 18;
    const stageOfDao = props.details[3];
    const tokenName = props.details[4];
    const tokenSymbol = props.details[5];
    const numProposals = props.details[6];

    const raisedPercent = Math.floor((1 - (yetToBeRaised / raiseGoal)) * 100);
  return (
    <div className="raiseCard">
      <p>{title}</p>
      <GetStatusLine raiseGoal={raiseGoal} raisedPercent={raisedPercent} stageOfDao={stageOfDao} />
      <p>{tokenName}({tokenSymbol})</p>
      <p>{numProposals} proposal(s)</p>
    </div>
  );
}

function EmptyRaiseDaoCard() {
    return (
        <div>
            <p>Work towards a goal, with a community, create a dao!</p>
        </div>
    )
}



export default CreateRaiseDaoCardLayout